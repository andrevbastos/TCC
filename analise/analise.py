#!/usr/bin/env python3
"""Análise estatística da campanha de pathfinding do TCC.

Segue o capítulo de Metodologia (typ/tcc/tcc_refac.typ, seções "Variáveis" a "Ameaças"):

- unidade experimental: terreno; valor do terreno = média dos ln das duas consultas (Par 0 e 1);
- métricas em escala ln: tempo de busca, vértices expandidos, pico da lista aberta e custo
  relativo (custo / custo do Dijkstra no mesmo terreno, representação e par; só Weighted A* e
  Greedy Best-First);
- ANOVA split-plot por teste e métrica: nível entre terrenos; algoritmo e representação dentro
  do terreno; cada efeito dentro do terreno contra sua interação com o terreno; correção de
  Greenhouse-Geisser em todos os efeitos dentro do terreno, sem teste de esfericidade; α = 0,05;
- Tukey dentro do terreno (erro da interação algoritmo × representação × terreno) e entre níveis
  (grupos independentes por par algoritmo × representação);
- Shapiro-Wilk dos resíduos dentro do terreno e entre terrenos;
- eta² parcial e razão das médias geométricas.

Uso:
    python analise.py <pasta_da_campanha> [--saida DIR] [--resumo ARQ] [--sims N]
"""

from __future__ import annotations

import argparse
import functools
import itertools
import re
import sys
from pathlib import Path

import numpy as np
import pandas as pd
from scipy import linalg, stats

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
from matplotlib.ticker import FixedLocator, FuncFormatter, MultipleLocator  # noqa: E402

ALPHA = 0.05

# Pastas de bloco: <prefixo_teste>_<grafo>; os arquivos do comprimento de onda usam "freq_".
TESTS = ["scale", "lac", "pers", "frequency"]
FILE_PREFIX = {"scale": "scale", "lac": "lac", "pers": "pers", "frequency": "freq"}
GRAPHS = ["2_5d", "voxel", "vertex", "dual"]
ALGORITHMS = ["Dijkstra", "A*", "Weighted A*", "Greedy Best-First"]
RELCOST_ALGORITHMS = ["Weighted A*", "Greedy Best-First"]
RUNS = 5
TERRAINS_PER_LEVEL = 50
LEVELS_PER_TEST = 4

TEST_LABEL = {
    "scale": "Escala",
    "lac": "Lacunaridade",
    "pers": "Persistência",
    "frequency": "Comprimento de onda",
}
GRAPH_LABEL = {
    "2_5d": "Grade 2.5D",
    "voxel": "Grade voxelizada",
    "vertex": "Grafo de vértices",
    "dual": "Grafo dual",
}
METRICS = ["tempo", "expandidos", "pico_open", "custo_relativo"]
METRIC_LABEL = {
    "tempo": "Tempo de busca",
    "expandidos": "Vértices expandidos",
    "pico_open": "Pico da lista aberta",
    "custo_relativo": "Custo relativo",
}

# Colunas usadas (por nome, exceto a do nível, que é a 2ª coluna e muda de nome por teste).
COL_ALG = "Algoritmo"
COL_SEED = "Seed do Terreno"
COL_PAIR = "Par"
COL_COST = "Custo do Caminho"
COL_EXPANDED = "Nós Expandidos"
COL_PEAK = "Pico da Open List"
# tempo_busca: busca sem construção do grafo; nas buscas < 5 ms é a mediana de k repetições
# (include/core/statistics.hpp e terrain_metrics.hpp). "Tempo de Execução" é a medição única.
COL_TIME = "tempo_busca"
COL_TIME_SINGLE = "Tempo de Execução"
COL_K = "k"

# Paleta categórica validada (dataviz/validate_palette.js, modo claro); marcadores distintos
# como codificação secundária, já que dois tons ficam abaixo de 3:1 de contraste.
GRAPH_COLOR = {"2_5d": "#2a78d6", "voxel": "#eb6834", "vertex": "#1baf7a", "dual": "#eda100"}
GRAPH_MARKER = {"2_5d": "o", "voxel": "s", "vertex": "^", "dual": "D"}


# ---------------------------------------------------------------------------------------
# Utilidades de formatação (vírgula decimal)
# ---------------------------------------------------------------------------------------

def br(x: float, digits: int = 3) -> str:
    if x is None or (isinstance(x, float) and not np.isfinite(x)):
        return "—"
    return f"{x:.{digits}f}".replace(".", ",")


def br_g(x: float, digits: int = 4) -> str:
    return f"{x:.{digits}g}".replace(".", ",")


def br_p(p: float) -> str:
    if p < 0.001:
        return "< 0,001"
    return br(p, 3)


def level_label(test: str, value: float) -> str:
    if test in ("scale", "frequency"):
        return f"{value:.0f}"
    return br_g(value, 3)


# ---------------------------------------------------------------------------------------
# Leitura
# ---------------------------------------------------------------------------------------

def read_campaign(root: Path, report: list[str]) -> pd.DataFrame:
    frames = []
    for test in TESTS:
        for graph in GRAPHS:
            for run in range(1, RUNS + 1):
                path = root / f"{test}_{graph}" / f"run_{run:02d}" / f"{FILE_PREFIX[test]}_{graph}.csv"
                if not path.is_file():
                    continue
                df = pd.read_csv(path)
                level_col = df.columns[1]
                df = df.rename(columns={level_col: "nivel"})
                df["coluna_nivel"] = level_col
                df["teste"] = test
                df["grafo"] = graph
                df["run"] = run
                frames.append(df)
    data = pd.concat(frames, ignore_index=True)
    return data


# ---------------------------------------------------------------------------------------
# Verificações de integridade
# ---------------------------------------------------------------------------------------

class Checks:
    def __init__(self) -> None:
        self.lines: list[str] = []
        self.failed = False

    def add(self, ok: bool | None, title: str, detail: str = "") -> None:
        tag = "OK" if ok else ("INFO" if ok is None else "FALHA")
        if ok is False:
            self.failed = True
        line = f"- **[{tag}]** {title}" + (f": {detail}" if detail else "")
        self.lines.append(line)
        print(f"[{tag}] {title}" + (f": {detail}" if detail else ""))

    def section(self, title: str) -> None:
        self.lines.append(f"\n## {title}\n")
        print(f"\n== {title}")


def integrity_checks(root: Path, data: pd.DataFrame, chk: Checks) -> None:
    chk.section("Arquivos e blocos")
    csvs = sorted(p for p in root.glob("*/run_*/*.csv"))
    chk.add(len(csvs) == 80, "Número de CSVs de resultado", f"{len(csvs)} (esperado 80)")

    blocks = data.groupby(["teste", "grafo"])["run"].nunique()
    full = (blocks == RUNS).sum()
    chk.add(len(blocks) == 16 and full == 16, "Blocos teste × grafo com 5 execuções",
            f"{len(blocks)} blocos, {full} com {RUNS} execuções")

    expected_rows = 4 * 4 * LEVELS_PER_TEST * TERRAINS_PER_LEVEL * 2 * 4
    chk.add(len(data) == expected_rows, "Número de linhas", f"{len(data)} (esperado {expected_rows})")

    names = data.groupby("teste")["coluna_nivel"].unique().apply(lambda v: ", ".join(v))
    chk.add(None, "Nome da 2ª coluna (nível) por teste",
            "; ".join(f"{t}: {names[t]}" for t in TESTS))

    chk.section("Terrenos")
    per_level = data.groupby(["teste", "grafo", "nivel"])[COL_SEED].nunique()
    chk.add(bool((per_level == TERRAINS_PER_LEVEL).all()) and
            bool((data.groupby(["teste", "grafo"])["nivel"].nunique() == LEVELS_PER_TEST).all()),
            "50 terrenos por nível em cada teste × grafo",
            f"mín {per_level.min()}, máx {per_level.max()} terrenos; {LEVELS_PER_TEST} níveis por bloco")

    per_run = data.groupby(["teste", "grafo", "nivel", "run"])[COL_SEED].nunique()
    chk.add(bool((per_run == 10).all()), "10 terrenos por nível em cada execução",
            f"mín {per_run.min()}, máx {per_run.max()}")

    same = True
    for test in TESTS:
        sets = {g: set(zip(*[data.loc[(data.teste == test) & (data.grafo == g), c]
                             for c in ("nivel", COL_SEED)])) for g in GRAPHS}
        same &= all(sets[g] == sets[GRAPHS[0]] for g in GRAPHS)
    chk.add(same, "Mesmos terrenos (nível, seed) nas quatro representações de cada teste")

    level_per_seed = data.groupby(["teste", COL_SEED])["nivel"].nunique()
    chk.add(bool((level_per_seed == 1).all()), "Cada seed pertence a um único nível dentro do teste")

    cells = data.groupby(["teste", "grafo", COL_SEED, COL_ALG, COL_PAIR]).size()
    combos = data.groupby(["teste", "grafo", COL_SEED]).apply(
        lambda d: set(zip(d[COL_ALG], d[COL_PAIR])), include_groups=False)
    expected = {(a, p) for a in ALGORITHMS for p in (0, 1)}
    chk.add(bool((cells == 1).all()) and all(c == expected for c in combos),
            "Cada terreno tem 4 algoritmos × 2 pares, sem duplicatas")

    cols = [COL_TIME, COL_EXPANDED, COL_PEAK, COL_COST]
    na = int(data[cols].isna().sum().sum())
    nonpos = int((data[cols] <= 0).sum().sum())
    chk.add(na == 0 and nonpos == 0, "Métricas sem ausentes e estritamente positivas (ln definido)",
            f"{na} ausentes, {nonpos} valores ≤ 0")

    chk.section("Coluna de tempo")
    eq = data[COL_TIME] == data[COL_TIME_SINGLE]
    long_ = data[COL_TIME_SINGLE] >= 0.005
    k1 = data[COL_K] == 1
    chk.add(bool((eq | ~long_).all()) and bool((data.loc[long_, COL_K] == 1).all()),
            f"Buscas com medição única ≥ 5 ms: k = 1 e '{COL_TIME}' = '{COL_TIME_SINGLE}'",
            f"{int(long_.sum())} linhas")
    chk.add(bool((data.loc[~long_, COL_K] >= 1).all()),
            f"Buscas com medição única < 5 ms: '{COL_TIME}' = mediana de k repetições",
            f"{int((~long_).sum())} linhas; k entre {int(data.loc[~long_, COL_K].min())} e "
            f"{int(data.loc[~long_, COL_K].max())}; {int((~long_ & k1).sum())} delas com k = 1 "
            f"(a única repetição já passou de 5 ms), das quais {int((~long_ & k1 & ~eq).sum())} "
            f"diferem de '{COL_TIME_SINGLE}'")
    chk.add(None, "Coluna usada como tempo de busca",
            f"'{COL_TIME}' (exclui a construção do grafo; inclui a inicialização dos vetores de "
            f"estado, registrada à parte em 'tempo_inicializacao')")

    chk.section("Custo relativo de Dijkstra e A*")
    rel = relative_cost_rows(data)
    dj = rel.loc[rel[COL_ALG] == "Dijkstra", "rel"]
    chk.add(bool((dj == 1.0).all()), "Custo relativo do Dijkstra = 1 em todas as linhas",
            f"{len(dj)} linhas")
    ast = rel.loc[rel[COL_ALG] == "A*"]
    exact = int((ast["rel"] == 1.0).sum())
    dev = float((ast["rel"] - 1).abs().max())
    chk.add(exact == len(ast), "Custo relativo do A* = 1 em todas as linhas",
            f"{exact}/{len(ast)} exatamente iguais; máx |rel − 1| = {dev:.3e}")
    below = int((rel["rel"] < 1.0).sum())
    chk.add(below == 0, "Nenhum algoritmo com custo menor que o do Dijkstra", f"{below} linhas")


def manifest_checks(root: Path, chk: Checks) -> None:
    chk.section("manifest.csv, sementes e commit")
    man = pd.read_csv(root / "manifest.csv")
    kept = man[man["mantida"] == 1] if "mantida" in man else man
    chk.add(len(man) == 80 and len(kept) == 80, "Linhas do manifest",
            f"{len(man)} linhas, {len(kept)} mantidas (tentativas > 1: {int((man['tentativa'] > 1).sum())})")
    chk.add(bool((kept["exit_code"] == 0).all()), "exit_code = 0 em todos os blocos mantidos",
            f"valores: {sorted(kept['exit_code'].unique().tolist())}")
    thr_cols = [c for c in ("throttle_core", "throttle_pkg", "throttle_ms") if c in kept]
    thr = kept[thr_cols].to_numpy()
    chk.add(bool((thr == 0).all()), "throttle = 0 em todos os blocos mantidos",
            ", ".join(f"{c} máx {int(kept[c].max())}" for c in thr_cols))
    blocks = kept.groupby(["teste", "grafo"])["run"].apply(lambda r: sorted(r.tolist()))
    chk.add(len(blocks) == 16 and all(b == list(range(1, RUNS + 1)) for b in blocks),
            "Manifest cobre 16 blocos × 5 execuções")
    commits = kept["commit"].unique().tolist()
    chk.add(None, "Commit registrado no manifest", ", ".join(commits)
            + f"; git_sujo = {sorted(kept['git_sujo'].unique().tolist())}")

    params = {}
    env = root / "params.env"
    if env.is_file():
        for line in env.read_text().splitlines():
            if "=" in line:
                k, v = line.split("=", 1)
                params[k.strip()] = v.strip().strip("'\"")
    base = int(params.get("BASE_SEED", "0"))
    run_seed = kept.groupby("run")["seed"].unique()
    derived = all(len(s) == 1 and int(s[0]) == base + r for r, s in run_seed.items())
    chk.add(derived, "Semente de cada execução = BASE_SEED + execução",
            f"BASE_SEED (params.env) = {base}; sementes por execução: "
            + ", ".join(f"{r}: {int(s[0])}" for r, s in run_seed.items()))

    logged = {}
    for log in root.glob("*/run_*/stdout.log"):
        m = re.search(r"Seed base:\s*(\d+)", log.read_text(errors="replace"))
        run = int(log.parent.name.split("_")[1])
        if m:
            logged.setdefault(run, set()).add(int(m.group(1)))
    ok = all(logged.get(r) == {base + r} for r in range(1, RUNS + 1))
    chk.add(ok, "'Seed base' do stdout.log = semente da execução no manifest",
            "; ".join(f"execução {r}: {sorted(logged.get(r, []))}" for r in range(1, RUNS + 1)))


# ---------------------------------------------------------------------------------------
# Agregação por terreno (média dos ln das duas consultas)
# ---------------------------------------------------------------------------------------

def relative_cost_rows(data: pd.DataFrame) -> pd.DataFrame:
    keys = ["teste", "grafo", COL_SEED, COL_PAIR]
    dij = data.loc[data[COL_ALG] == "Dijkstra", keys + [COL_COST]].rename(columns={COL_COST: "custo_dij"})
    out = data.merge(dij, on=keys, how="left", validate="many_to_one")
    out["rel"] = out[COL_COST] / out["custo_dij"]
    return out


def terrain_table(data: pd.DataFrame) -> pd.DataFrame:
    """Uma linha por teste × terreno × grafo × algoritmo, com a média dos ln das duas consultas."""
    rel = relative_cost_rows(data)
    rel["ln_tempo"] = np.log(rel[COL_TIME])
    rel["ln_expandidos"] = np.log(rel[COL_EXPANDED])
    rel["ln_pico_open"] = np.log(rel[COL_PEAK])
    rel["ln_custo_relativo"] = np.log(rel["rel"])
    keys = ["teste", "nivel", COL_SEED, "grafo", COL_ALG]
    agg = rel.groupby(keys, as_index=False)[[f"ln_{m}" for m in METRICS]].mean()
    npairs = rel.groupby(keys)[COL_PAIR].nunique()
    assert (npairs == 2).all()
    agg = agg.rename(columns={COL_SEED: "seed", COL_ALG: "algoritmo"})
    return agg


def to_array(tt: pd.DataFrame, test: str, metric: str, algorithms: list[str]):
    """Array Y[a, n, b, c]: nível × terreno no nível × algoritmo × representação."""
    d = tt[(tt.teste == test) & (tt.algoritmo.isin(algorithms))]
    levels = sorted(d.nivel.unique())
    a, b, c = len(levels), len(algorithms), len(GRAPHS)
    seeds_by_level = [sorted(d.loc[d.nivel == lv, "seed"].unique()) for lv in levels]
    n = len(seeds_by_level[0])
    assert all(len(s) == n for s in seeds_by_level), "desenho desbalanceado"
    d = d.assign(algoritmo=pd.Categorical(d.algoritmo, algorithms, ordered=True),
                 grafo=pd.Categorical(d.grafo, GRAPHS, ordered=True))
    d = d.sort_values(["nivel", "seed", "algoritmo", "grafo"])
    assert len(d) == a * n * b * c
    Y = d[f"ln_{metric}"].to_numpy().reshape(a, n, b, c)
    # Confere a ordem dos índices após o reshape.
    assert (d["nivel"].to_numpy().reshape(a, n, b, c) == np.array(levels)[:, None, None, None]).all()
    assert (d["grafo"].cat.codes.to_numpy().reshape(a, n, b, c) == np.arange(c)).all()
    assert (d["algoritmo"].cat.codes.to_numpy().reshape(a, n, b, c) == np.arange(b)[:, None]).all()
    assert np.isfinite(Y).all()
    return Y, levels


# ---------------------------------------------------------------------------------------
# ANOVA split-plot balanceada (1 fator entre, 2 fatores dentro) com Greenhouse-Geisser
# ---------------------------------------------------------------------------------------

def orth_contrasts(k: int) -> np.ndarray:
    """Base ortonormal (k × (k−1)) do complemento do vetor de uns."""
    return linalg.null_space(np.ones((1, k)))


def gg_epsilon(Y: np.ndarray, M: np.ndarray) -> float:
    """ε de Greenhouse-Geisser a partir da covariância intragrupo agrupada dos contrastes."""
    a, n, b, c = Y.shape
    Z = Y.reshape(a, n, b * c) @ M
    Zc = Z - Z.mean(axis=1, keepdims=True)
    S = np.einsum("anp,anq->pq", Zc, Zc) / (a * (n - 1))
    p = M.shape[1]
    return float(np.trace(S) ** 2 / (p * np.trace(S @ S)))


def split_plot_anova(Y: np.ndarray) -> pd.DataFrame:
    """Y[a, n, b, c]: A = entre terrenos (nível), S(A) = terreno, B e C = dentro do terreno."""
    a, n, b, c = Y.shape
    G = Y.mean()
    mA = Y.mean(axis=(1, 2, 3))
    mS = Y.mean(axis=(2, 3))
    mB = Y.mean(axis=(0, 1, 3))
    mC = Y.mean(axis=(0, 1, 2))
    mAB = Y.mean(axis=(1, 3))
    mAC = Y.mean(axis=(1, 2))
    mBC = Y.mean(axis=(0, 1))
    mABC = Y.mean(axis=1)
    mSB = Y.mean(axis=3)
    mSC = Y.mean(axis=2)
    A_ = mA[:, None, None, None]
    S_ = mS[:, :, None, None]

    ss = {}
    ss["A"] = n * b * c * np.sum((mA - G) ** 2)
    ss["S(A)"] = b * c * np.sum((mS - mA[:, None]) ** 2)
    ss["B"] = a * n * c * np.sum((mB - G) ** 2)
    ss["A×B"] = n * c * np.sum((mAB - mA[:, None] - mB[None, :] + G) ** 2)
    ss["B×S(A)"] = c * np.sum((mSB - mS[:, :, None] - mAB[:, None, :] + mA[:, None, None]) ** 2)
    ss["C"] = a * n * b * np.sum((mC - G) ** 2)
    ss["A×C"] = n * b * np.sum((mAC - mA[:, None] - mC[None, :] + G) ** 2)
    ss["C×S(A)"] = b * np.sum((mSC - mS[:, :, None] - mAC[:, None, :] + mA[:, None, None]) ** 2)
    ss["B×C"] = a * n * np.sum((mBC - mB[:, None] - mC[None, :] + G) ** 2)
    ss["A×B×C"] = n * np.sum((mABC - mAB[:, :, None] - mAC[:, None, :] - mBC[None]
                              + mA[:, None, None] + mB[None, :, None] + mC[None, None, :] - G) ** 2)
    ss["B×C×S(A)"] = np.sum((Y - mSB[..., None] - mSC[:, :, None, :] - mABC[:, None]
                             + S_ + mAB[:, None, :, None] + mAC[:, None, None, :] - A_) ** 2)
    ss_total = np.sum((Y - G) ** 2)
    assert np.isclose(sum(ss.values()), ss_total, rtol=1e-9, atol=1e-9), "decomposição não fecha"

    df = {
        "A": a - 1, "S(A)": a * (n - 1),
        "B": b - 1, "A×B": (a - 1) * (b - 1), "B×S(A)": (b - 1) * a * (n - 1),
        "C": c - 1, "A×C": (a - 1) * (c - 1), "C×S(A)": (c - 1) * a * (n - 1),
        "B×C": (b - 1) * (c - 1), "A×B×C": (a - 1) * (b - 1) * (c - 1),
        "B×C×S(A)": (b - 1) * (c - 1) * a * (n - 1),
    }

    Mb, Mc = orth_contrasts(b), orth_contrasts(c)
    ub, uc = np.ones((b, 1)) / np.sqrt(b), np.ones((c, 1)) / np.sqrt(c)
    eps = {
        "B": gg_epsilon(Y, np.kron(Mb, uc)) if b > 2 else 1.0,
        "C": gg_epsilon(Y, np.kron(ub, Mc)) if c > 2 else 1.0,
        "B×C": gg_epsilon(Y, np.kron(Mb, Mc)) if (b - 1) * (c - 1) > 1 else 1.0,
    }

    tests = [
        ("A", "S(A)", None),
        ("B", "B×S(A)", "B"), ("A×B", "B×S(A)", "B"),
        ("C", "C×S(A)", "C"), ("A×C", "C×S(A)", "C"),
        ("B×C", "B×C×S(A)", "B×C"), ("A×B×C", "B×C×S(A)", "B×C"),
    ]
    rows = []
    for eff, err, ekey in tests:
        ms_e, ms_r = ss[eff] / df[eff], ss[err] / df[err]
        F = ms_e / ms_r
        e = eps[ekey] if ekey else np.nan
        p_unc = stats.f.sf(F, df[eff], df[err])
        p_gg = stats.f.sf(F, e * df[eff], e * df[err]) if ekey else p_unc
        rows.append({
            "efeito": eff, "erro": err, "SS": ss[eff], "gl": df[eff], "SS_erro": ss[err],
            "gl_erro": df[err], "MS": ms_e, "MS_erro": ms_r, "F": F, "p_sem_correcao": p_unc,
            "epsilon_GG": e,
            "gl_GG": e * df[eff] if ekey else df[eff],
            "gl_erro_GG": e * df[err] if ekey else df[err],
            "p_GG": p_gg,
            "eta2_parcial": ss[eff] / (ss[eff] + ss[err]),
        })
    out = pd.DataFrame(rows)
    out.attrs["ss"] = ss
    out.attrs["df"] = df
    return out


# ---------------------------------------------------------------------------------------
# Validação da ANOVA com dados simulados
# ---------------------------------------------------------------------------------------

def theoretical_epsilon(Sigma: np.ndarray, M: np.ndarray) -> float:
    S = M.T @ Sigma @ M
    return float(np.trace(S) ** 2 / (M.shape[1] * np.trace(S @ S)))


def simulate(rng, a, n, b, c, effA, effB, effC, effBC, Sigma, sd_subject):
    mu = (effA[:, None, None] + effB[None, :, None] + effC[None, None, :] + effBC[None]).reshape(a, b * c)
    L = np.linalg.cholesky(Sigma)
    E = rng.standard_normal((a, n, b * c)) @ L.T
    subj = rng.normal(0.0, sd_subject, (a, n, 1))
    return (mu[:, None, :] + subj + E).reshape(a, n, b, c)


def validate_anova(chk: Checks, sims: int, seed: int = 12345) -> None:
    import statsmodels.formula.api as smf
    from statsmodels.stats.anova import anova_lm

    chk.section("Validação da ANOVA split-plot (dados simulados)")
    rng = np.random.default_rng(seed)
    a, b, c = 4, 4, 4

    # Covariância dentro do terreno não esférica (variâncias heterogêneas + correlação AR(1)).
    sds = np.linspace(0.5, 1.6, b * c)
    idx = np.arange(b * c)
    R = 0.6 ** np.abs(idx[:, None] - idx[None, :])
    Sigma = np.outer(sds, sds) * R

    # 1) Mesmas SS e F de um OLS com termos de terreno (statsmodels, SS tipo I, desenho balanceado).
    n_small = 6
    effA = np.array([0.0, 0.3, 0.6, 0.9])
    effB = np.array([0.0, 0.5, -0.4, 1.0])
    effC = np.array([0.0, -0.3, 0.2, 0.7])
    effBC = rng.normal(0, 0.2, (b, c))
    Y = simulate(rng, a, n_small, b, c, effA, effB, effC, effBC, Sigma, 0.8)
    res = split_plot_anova(Y)
    ia, isub, ib, ic = np.meshgrid(*[np.arange(s) for s in Y.shape], indexing="ij")
    long = pd.DataFrame({"y": Y.ravel(), "fa": ia.ravel(), "fb": ib.ravel(), "fc": ic.ravel(),
                         "sj": isub.ravel()})
    # Terreno codificado como aninhado no nível (C(fa):C(sj)), para o desenho ficar de posto completo.
    fit = smf.ols("y ~ C(fa)*C(fb)*C(fc) + C(fa):C(sj) + C(fa):C(sj):C(fb) + C(fa):C(sj):C(fc)",
                  data=long).fit()
    tab = anova_lm(fit, typ=1)
    ref = {
        "A": tab.loc["C(fa)", "sum_sq"], "B": tab.loc["C(fb)", "sum_sq"], "C": tab.loc["C(fc)", "sum_sq"],
        "A×B": tab.loc["C(fa):C(fb)", "sum_sq"], "A×C": tab.loc["C(fa):C(fc)", "sum_sq"],
        "B×C": tab.loc["C(fb):C(fc)", "sum_sq"], "A×B×C": tab.loc["C(fa):C(fb):C(fc)", "sum_sq"],
        "S(A)": tab.loc["C(fa):C(sj)", "sum_sq"], "B×S(A)": tab.loc["C(fa):C(sj):C(fb)", "sum_sq"],
        "C×S(A)": tab.loc["C(fa):C(sj):C(fc)", "sum_sq"], "B×C×S(A)": tab.loc["Residual", "sum_sq"],
    }
    ss = res.attrs["ss"]
    maxrel = max(abs(ss[k] - ref[k]) / max(abs(ref[k]), 1e-12) for k in ref)
    chk.add(maxrel < 1e-8, "SS de todos os termos = OLS do statsmodels (SS tipo I com termos de terreno)",
            f"máx. erro relativo {maxrel:.2e}")
    names = {"A": "C(fa)", "B": "C(fb)", "C": "C(fc)", "A×B": "C(fa):C(fb)", "A×C": "C(fa):C(fc)",
             "B×C": "C(fb):C(fc)", "A×B×C": "C(fa):C(fb):C(fc)", "S(A)": "C(fa):C(sj)",
             "B×S(A)": "C(fa):C(sj):C(fb)", "C×S(A)": "C(fa):C(sj):C(fc)", "B×C×S(A)": "Residual"}
    gl_ok = all(int(round(tab.loc[t, "df"])) == res.attrs["df"][k] for k, t in names.items())
    chk.add(gl_ok, "Graus de liberdade de todos os termos conferem com o OLS")

    # 2) ε estimado converge para o ε teórico da covariância simulada; ε = 1 sob esfericidade.
    n_big = 2000
    Yb = simulate(rng, a, n_big, b, c, np.zeros(a), np.zeros(b), np.zeros(c), np.zeros((b, c)), Sigma, 0.8)
    rb = split_plot_anova(Yb).set_index("efeito")
    Mb, Mc = orth_contrasts(b), orth_contrasts(c)
    ub, uc = np.ones((b, 1)) / np.sqrt(b), np.ones((c, 1)) / np.sqrt(c)
    teo = {"B": theoretical_epsilon(Sigma, np.kron(Mb, uc)),
           "C": theoretical_epsilon(Sigma, np.kron(ub, Mc)),
           "B×C": theoretical_epsilon(Sigma, np.kron(Mb, Mc))}
    diffs = {k: abs(rb.loc[k, "epsilon_GG"] - teo[k]) for k in teo}
    chk.add(max(diffs.values()) < 0.02, "ε de Greenhouse-Geisser estimado ≈ ε teórico (n = 2000 por nível)",
            "; ".join(f"{k}: {rb.loc[k, 'epsilon_GG']:.3f} vs {teo[k]:.3f}" for k in teo))
    Ys = simulate(rng, a, n_big, b, c, np.zeros(a), np.zeros(b), np.zeros(c), np.zeros((b, c)),
                  np.eye(b * c), 0.8)
    rs = split_plot_anova(Ys).set_index("efeito")
    chk.add(all(rs.loc[k, "epsilon_GG"] > 0.97 for k in teo), "ε ≈ 1 com covariância esférica",
            ", ".join(f"{k}: {rs.loc[k, 'epsilon_GG']:.3f}" for k in teo))

    # 3) Efeitos conhecidos: médias marginais recuperadas.
    n_mid = 50
    effBC0 = np.zeros((b, c))
    effBC0[3, 3] = 0.8
    Yk = simulate(rng, a, n_mid * 20, b, c, effA, effB, effC, effBC0, Sigma, 0.8)
    est_B = Yk.mean(axis=(0, 1, 3))
    true_B = effB + effBC0.mean(axis=1)
    est_C = Yk.mean(axis=(0, 1, 2))
    true_C = effC + effBC0.mean(axis=0)
    est_A = Yk.mean(axis=(1, 2, 3))
    errs = [np.max(np.abs((est_B - est_B.mean()) - (true_B - true_B.mean()))),
            np.max(np.abs((est_C - est_C.mean()) - (true_C - true_C.mean()))),
            np.max(np.abs((est_A - est_A.mean()) - (effA - effA.mean())))]
    chk.add(max(errs) < 0.1, "Médias marginais simuladas recuperadas (efeitos de A, B e C conhecidos)",
            f"máx. desvio {max(errs):.3f} (escala ln)")

    # 4) Erro tipo I em n = 50 por nível (desenho real), covariância não esférica.
    rej_unc = {k: 0 for k in ["A", "B", "C", "B×C", "A×B", "A×C", "A×B×C"]}
    rej_gg = dict(rej_unc)
    for _ in range(sims):
        Yn = simulate(rng, a, n_mid, b, c, np.zeros(a), np.zeros(b), np.zeros(c), np.zeros((b, c)),
                      Sigma, 0.8)
        r = split_plot_anova(Yn).set_index("efeito")
        for k in rej_unc:
            rej_unc[k] += r.loc[k, "p_sem_correcao"] < ALPHA
            rej_gg[k] += r.loc[k, "p_GG"] < ALPHA
    rate_gg = {k: v / sims for k, v in rej_gg.items()}
    rate_unc = {k: v / sims for k, v in rej_unc.items()}
    # Banda binomial de ~3 erros-padrão em torno de α (o GG pode ser levemente conservador).
    tol = 3 * np.sqrt(ALPHA * (1 - ALPHA) / sims)
    ok = all(v <= ALPHA + tol for v in rate_gg.values())
    chk.add(ok, f"Erro tipo I sob H0 com GG ≤ α (+3 EP) em {sims} simulações, n = 50 por nível",
            "GG: " + ", ".join(f"{k} {v:.3f}" for k, v in rate_gg.items())
            + " | sem correção: " + ", ".join(f"{k} {v:.3f}" for k, v in rate_unc.items()))

    # 5) Poder simulado = poder teórico (F não central) para efeitos conhecidos, com covariância
    #    esférica (onde a distribuição exata é conhecida).
    sd_s, sigma = 0.8, 1.0
    effA_p = np.array([0.0, 0.15, 0.30, 0.45])
    effB_p = np.array([0.0, 0.05, 0.10, 0.15])
    effC_p = np.array([0.0, 0.10, 0.05, 0.15])
    effBC_p = np.zeros((b, c))
    effBC_p[0, 0], effBC_p[3, 3] = 0.25, -0.25
    # Interação centrada, para não alterar os efeitos principais de B e C.
    inter = effBC_p - effBC_p.mean(1, keepdims=True) - effBC_p.mean(0, keepdims=True) + effBC_p.mean()
    df_ = split_plot_anova(np.zeros((a, n_mid, b, c)) + rng.normal(size=(a, n_mid, b, c))).attrs["df"]
    lam = {
        "A": n_mid * np.sum((effA_p - effA_p.mean()) ** 2) / (sd_s ** 2 + sigma ** 2 / (b * c)),
        "B": a * n_mid * c * np.sum((effB_p - effB_p.mean()) ** 2) / sigma ** 2,
        "C": a * n_mid * b * np.sum((effC_p - effC_p.mean()) ** 2) / sigma ** 2,
        "B×C": a * n_mid * np.sum(inter ** 2) / sigma ** 2,
    }
    err = {"A": "S(A)", "B": "B×S(A)", "C": "C×S(A)", "B×C": "B×C×S(A)"}
    theo = {k: float(stats.ncf.sf(stats.f.ppf(1 - ALPHA, df_[k], df_[err[k]]), df_[k], df_[err[k]], lam[k]))
            for k in lam}
    hits = {k: 0 for k in lam}
    for _ in range(sims):
        Yp = simulate(rng, a, n_mid, b, c, effA_p, effB_p, effC_p, inter, sigma ** 2 * np.eye(b * c), sd_s)
        r = split_plot_anova(Yp).set_index("efeito")
        for k in hits:
            hits[k] += r.loc[k, "p_sem_correcao"] < ALPHA
    sim_pw = {k: v / sims for k, v in hits.items()}
    ok = all(abs(sim_pw[k] - theo[k]) <= 3 * np.sqrt(theo[k] * (1 - theo[k]) / sims) for k in lam)
    chk.add(ok, f"Poder simulado = poder teórico do F não central ({sims} simulações, ±3 EP)",
            ", ".join(f"{k} {sim_pw[k]:.3f} vs {theo[k]:.3f}" for k in lam))

    # 6) Tukey entre níveis = scipy.stats.tukey_hsd para grupos independentes.
    groups = [rng.normal(m, 1.0, n_mid) for m in (0, 0.2, 0.5, 0.6)]
    mine = tukey_independent(np.array(groups))
    ref_t = stats.tukey_hsd(*groups).pvalue
    dmax = max(abs(r["p"] - ref_t[r["i"], r["j"]]) for r in mine)
    chk.add(dmax < 1e-3, "Tukey entre níveis = scipy.stats.tukey_hsd", f"máx |Δp| = {dmax:.1e}")


# ---------------------------------------------------------------------------------------
# Tukey
# ---------------------------------------------------------------------------------------

@functools.lru_cache(maxsize=None)
def q_critical(k: int, dfe: int) -> float:
    """Quantil 1 − α da amplitude studentizada (cálculo numérico lento; reaproveitado)."""
    return float(stats.studentized_range.ppf(1 - ALPHA, k, dfe))


def tukey_independent(groups: np.ndarray) -> list[dict]:
    """groups[a, n]: Tukey HSD com grupos independentes e MSE agrupado."""
    a, n = groups.shape
    means = groups.mean(axis=1)
    mse = np.sum((groups - means[:, None]) ** 2) / (a * (n - 1))
    dfe = a * (n - 1)
    se = np.sqrt(mse / n)
    qcrit = q_critical(a, dfe)
    out = []
    for i, j in itertools.combinations(range(a), 2):
        d = means[i] - means[j]
        q = abs(d) / se
        out.append({"i": i, "j": j, "dif_ln": d, "q": q, "gl_erro": dfe, "MS_erro": mse,
                    "p": float(stats.studentized_range.sf(q, a, dfe)),
                    "li": d - qcrit * se, "ls": d + qcrit * se})
    return out


def tukey_within(means: np.ndarray, mse: float, dfe: int, n_obs: int) -> list[dict]:
    k = len(means)
    se = np.sqrt(mse / n_obs)
    qcrit = q_critical(k, dfe)
    out = []
    for i, j in itertools.combinations(range(k), 2):
        d = means[i] - means[j]
        q = abs(d) / se
        out.append({"i": i, "j": j, "dif_ln": d, "q": q, "gl_erro": dfe, "MS_erro": mse,
                    "p": float(stats.studentized_range.sf(q, k, dfe)),
                    "li": d - qcrit * se, "ls": d + qcrit * se})
    return out


# ---------------------------------------------------------------------------------------
# Análise de um teste × métrica
# ---------------------------------------------------------------------------------------

def analyse(tt: pd.DataFrame, test: str, metric: str):
    algs = RELCOST_ALGORITHMS if metric == "custo_relativo" else ALGORITHMS
    Y, levels = to_array(tt, test, metric, algs)
    a, n, b, c = Y.shape

    anova = split_plot_anova(Y)
    anova.insert(0, "metrica", metric)
    anova.insert(0, "teste", test)

    # Resíduos: entre terrenos (média do terreno − média do nível) e dentro do terreno
    # (y − média do terreno − média da célula nível×alg×rep + média do nível).
    mS = Y.mean(axis=(2, 3))
    mA = Y.mean(axis=(1, 2, 3))
    mABC = Y.mean(axis=1)
    r_between = (mS - mA[:, None]).ravel()
    r_within = (Y - mS[:, :, None, None] - mABC[:, None] + mA[:, None, None, None]).ravel()
    sw = []
    for name, r in (("entre terrenos", r_between), ("dentro do terreno", r_within)):
        W, p = stats.shapiro(r)
        sw.append({"teste": test, "metrica": metric, "estrato": name, "n": len(r), "W": W, "p": p})

    # Tukey dentro do terreno, com o erro da interação algoritmo × representação × terreno.
    eff = anova.set_index("efeito")
    mse_bc = float(eff.loc["B×C", "MS_erro"])
    df_bc = int(eff.loc["B×C", "gl_erro"])
    mBC = Y.mean(axis=(0, 1))
    tw = []
    for j, alg in enumerate(algs):
        for r in tukey_within(mBC[j, :], mse_bc, df_bc, a * n):
            tw.append({"teste": test, "metrica": metric, "comparacao": "representações por algoritmo",
                       "fixo": alg, "grupo_1": GRAPHS[r["i"]], "grupo_2": GRAPHS[r["j"]], **r})
    for k, g in enumerate(GRAPHS):
        for r in tukey_within(mBC[:, k], mse_bc, df_bc, a * n):
            tw.append({"teste": test, "metrica": metric, "comparacao": "algoritmos por representação",
                       "fixo": g, "grupo_1": algs[r["i"]], "grupo_2": algs[r["j"]], **r})
    tw = pd.DataFrame(tw)

    tl = []
    for j, alg in enumerate(algs):
        for k, g in enumerate(GRAPHS):
            for r in tukey_independent(Y[:, :, j, k]):
                tl.append({"teste": test, "metrica": metric, "algoritmo": alg, "grafo": g,
                           "nivel_1": levels[r["i"]], "nivel_2": levels[r["j"]], **r})
    tl = pd.DataFrame(tl)
    for t in (tw, tl):
        t.drop(columns=["i", "j"], inplace=True)
        t["razao_mg"] = np.exp(t["dif_ln"])
        t["razao_mg_li"] = np.exp(t["li"])
        t["razao_mg_ls"] = np.exp(t["ls"])
        t["significativo"] = t["p"] < ALPHA
        t.drop(columns=["li", "ls"], inplace=True)

    # Médias geométricas marginais (exp da média dos ln dos terrenos).
    gm = {
        "nivel": dict(zip(levels, np.exp(Y.mean(axis=(1, 2, 3))))),
        "algoritmo": dict(zip(algs, np.exp(Y.mean(axis=(0, 1, 3))))),
        "grafo": dict(zip(GRAPHS, np.exp(Y.mean(axis=(0, 1, 2))))),
        "alg_grafo": np.exp(mBC),
    }
    return anova, pd.DataFrame(sw), tw, tl, gm, levels, algs


def descriptive(tt: pd.DataFrame) -> pd.DataFrame:
    rows = []
    for (test, lv, alg, g), d in tt.groupby(["teste", "nivel", "algoritmo", "grafo"]):
        for m in METRICS:
            if m == "custo_relativo" and alg not in RELCOST_ALGORITHMS:
                continue
            v = np.exp(d[f"ln_{m}"].to_numpy())  # média geométrica das duas consultas do terreno
            q1, med, q3 = np.percentile(v, [25, 50, 75])
            ln = d[f"ln_{m}"].to_numpy()
            mean_ln, sd_ln = ln.mean(), ln.std(ddof=1)
            half = stats.t.ppf(0.975, len(ln) - 1) * sd_ln / np.sqrt(len(ln))
            rows.append({"teste": test, "nivel": lv, "algoritmo": alg, "grafo": g, "metrica": m,
                         "n_terrenos": len(v), "mediana": med, "q1": q1, "q3": q3, "iiq": q3 - q1,
                         "media_geometrica": float(np.exp(mean_ln)),
                         "ic95_inf": float(np.exp(mean_ln - half)),
                         "ic95_sup": float(np.exp(mean_ln + half))})
    out = pd.DataFrame(rows)
    out["teste"] = pd.Categorical(out["teste"], TESTS, ordered=True)
    out["algoritmo"] = pd.Categorical(out["algoritmo"], ALGORITHMS, ordered=True)
    out["grafo"] = pd.Categorical(out["grafo"], GRAPHS, ordered=True)
    return out.sort_values(["teste", "metrica", "algoritmo", "grafo", "nivel"]).reset_index(drop=True)


# ---------------------------------------------------------------------------------------
# Figuras
# ---------------------------------------------------------------------------------------

def _fmt_br(x, _pos):
    """Número em notação pt-BR, sem notação científica (1.000.000; 0,5)."""
    if x <= 0:
        return ""
    if x >= 1000:
        return f"{x:,.0f}".replace(",", ".")
    return f"{x:.3g}".replace(".", ",")


def log_ticks(ax) -> None:
    """Marcas numeradas no eixo log: o primeiro conjunto entre 1, 1-3, 1-2-5, 1-2-3-5 e 1…9 (×10^k) com
    3 a 6 marcas e sem borda a mais de 0,3 década de uma marca (senão, o primeiro com 3 a 6). O intervalo do eixo é mantido."""
    lo, hi = ax.get_ylim()
    k0, k1 = int(np.floor(np.log10(lo))), int(np.ceil(np.log10(hi)))
    candidates = []
    for subs in ((1,), (1, 3), (1, 2, 5), (1, 2, 3, 5), (1, 2, 3, 4, 5, 6, 7, 8, 9)):
        t = [m * 10.0 ** k for k in range(k0, k1 + 1) for m in subs if lo <= m * 10.0 ** k <= hi]
        if 3 <= len(t) <= 6:
            candidates.append(t)
    # Prefere o primeiro conjunto sem borda a mais de 0,3 década de uma marca; senão, o primeiro
    # com 3 a 6 marcas.
    good = [t for t in candidates
            if np.log10(t[0] / lo) <= 0.3 and np.log10(hi / t[-1]) <= 0.3]
    ticks = good[0] if good else (candidates[0] if candidates else
                                  [m * 10.0 ** k for k in range(k0, k1 + 1) for m in (1, 2, 5)])
    ax.yaxis.set_major_locator(FixedLocator(ticks))
    ax.yaxis.set_minor_formatter(FuncFormatter(lambda x, p: ""))
    ax.set_ylim(lo, hi)


def _fmt_2dec(x, _pos):
    return f"{x:.2f}".replace(".", ",")


def regular_ticks(ax) -> None:
    """Marcas em múltiplos regulares (0,01/0,02/0,05/0,1...), com o eixo começando numa marca."""
    lo, hi = ax.dataLim.y0, ax.dataLim.y1  # extremos dos pontos e barras, sem a margem automática
    for step in (0.01, 0.02, 0.05, 0.1, 0.2, 0.5):
        if (hi - lo) / step <= 8:
            break
    lo_t = np.floor(lo / step + 1e-9) * step
    hi_t = np.ceil(hi / step - 1e-9) * step
    if hi_t - hi < 0.15 * step:  # folga para os marcadores no topo
        hi_t += step
    ax.set_ylim(lo_t, hi_t)
    ax.yaxis.set_major_locator(MultipleLocator(step))
    ax.yaxis.set_major_formatter(FuncFormatter(_fmt_2dec))


def plot_metric(desc: pd.DataFrame, test: str, metric: str, out: Path) -> pd.DataFrame:
    """Desenha a figura e devolve os pontos plotados (valores na escala original)."""
    algs = RELCOST_ALGORITHMS if metric == "custo_relativo" else ALGORITHMS
    d = desc[(desc.teste == test) & (desc.metrica == metric)]
    levels = sorted(d.nivel.unique())
    scale = 1000.0 if metric == "tempo" else 1.0
    ncols = 2
    nrows = int(np.ceil(len(algs) / ncols))
    plt.rcParams.update({"font.size": 9, "axes.spines.top": False, "axes.spines.right": False})
    fig, axes = plt.subplots(nrows, ncols, figsize=(7.0, 2.6 * nrows + 0.6), squeeze=False)
    offsets = np.linspace(-0.12, 0.12, len(GRAPHS))
    plotted = []
    for ax, alg in zip(axes.ravel(), algs):
        for off, g in zip(offsets, GRAPHS):
            s = d[(d.algoritmo == alg) & (d.grafo == g)].sort_values("nivel")
            x = np.arange(len(levels)) + off
            gm = s["media_geometrica"].to_numpy() * scale
            lo = gm - s["ic95_inf"].to_numpy() * scale
            hi = s["ic95_sup"].to_numpy() * scale - gm
            plotted.append(pd.DataFrame({"teste": test, "metrica": metric, "algoritmo": alg, "grafo": g,
                                         "nivel": s["nivel"].to_numpy(), "valor_plotado": gm / scale}))
            ax.errorbar(x, gm, yerr=[lo, hi], color=GRAPH_COLOR[g], marker=GRAPH_MARKER[g],
                        markersize=4.5, linewidth=1.5, elinewidth=1.0, capsize=2,
                        label=GRAPH_LABEL[g])
        ax.set_title(alg, fontsize=10)
        ax.set_xticks(np.arange(len(levels)))
        ax.set_xticklabels([level_label(test, v) for v in levels])
        ax.set_xlabel(TEST_LABEL[test])
        if metric != "custo_relativo":
            ax.set_yscale("log")
        ax.yaxis.set_major_formatter(FuncFormatter(_fmt_br))
        ax.yaxis.set_minor_formatter(FuncFormatter(lambda x, p: ""))
        if metric == "custo_relativo":
            regular_ticks(ax)
        else:
            log_ticks(ax)
        unit = " (ms)" if metric == "tempo" else ""
        ax.set_ylabel(METRIC_LABEL[metric] + unit)
        ax.grid(axis="y", color="#d9d9d6", linewidth=0.6)
    for ax in axes.ravel()[len(algs):]:
        ax.set_visible(False)
    handles, labels = axes[0, 0].get_legend_handles_labels()
    fig.legend(handles, labels, loc="upper center", ncol=4, frameon=False, fontsize=8.5)
    fig.text(0.5, 0.005, "Média geométrica dos terrenos; barras: intervalo de confiança de 95%.", ha="center",
             fontsize=7.5, color="#555555")
    fig.tight_layout(rect=(0, 0.03, 1, 0.94))
    fig.savefig(out, dpi=300)
    plt.close(fig)
    return pd.concat(plotted, ignore_index=True)



# ---------------------------------------------------------------------------------------
# Conferência das figuras
# ---------------------------------------------------------------------------------------

_NUM = r"(-?\d+(?:,\d+)?)"


def _parse_br(txt: str) -> tuple[float, float]:
    """Número com vírgula decimal -> (valor, tolerância de meia unidade da última casa exibida)."""
    txt = txt.strip()
    dec = len(txt.split(",")[1]) if "," in txt else 0
    return float(txt.replace(",", ".")), 0.5 * 10 ** (-dec)


def parse_summary(path: Path) -> dict:
    """Lê do resumo as médias geométricas marginais por nível e a tabela algoritmo × representação."""
    test_by_label = {v: k for k, v in TEST_LABEL.items()}
    metric_by_label = {v: k for k, v in METRIC_LABEL.items()}
    graph_by_label = {v: k for k, v in GRAPH_LABEL.items()}
    out = {"nivel": {}, "alg_grafo": {}}
    test = metric = None
    in_table = False  # dentro da tabela "Média geométrica por algoritmo × representação"
    header = None
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith("## "):
            test = test_by_label.get(line[3:].strip())
        elif line.startswith("### "):
            metric = metric_by_label.get(line[4:].strip())
        elif line.startswith("- Nível: ") and test and metric:
            for item in line[len("- Nível: "):].split("; "):
                lv, val = item.split(" = ")
                out["nivel"][(test, metric, lv.strip())] = _parse_br(val.replace(" ms", ""))
        elif line.startswith("Média geométrica por algoritmo × representação"):
            in_table, header = True, None
        elif in_table and line.startswith("| Algoritmo |"):
            header = [graph_by_label[h.strip()] for h in line.strip("|").split("|")[1:]]
        elif in_table and header and line.startswith("|") and not line.startswith("|---"):
            cells = [c.strip() for c in line.strip("|").split("|")]
            for g, val in zip(header, cells[1:]):
                out["alg_grafo"][(test, metric, cells[0], g)] = _parse_br(val.replace(" ms", ""))
        elif in_table and header and not line.startswith("|"):
            in_table, header = False, None
    return out


def verify_figures(points: pd.DataFrame, terrain_csv: Path, summary: Path, out: Path) -> bool:
    """Confere cada ponto plotado contra o recálculo a partir do CSV por terreno e contra o resumo."""
    L = ["# Conferência das figuras\n",
         "Ponto plotado = média geométrica da célula teste × nível × algoritmo × representação "
         "(exp da média dos ln por terreno, n = 50); barras = IC de 95% na escala ln, "
         "exp(m ± t(0,975; 49)·s/√50).\n"]
    ok_all = True

    # (a) Cada ponto contra o recálculo independente a partir de dados_por_terreno_ln.csv.
    tt = pd.read_csv(terrain_csv)
    divs_a = []
    for _, r in points.iterrows():
        d = tt[(tt.teste == r.teste) & (tt.algoritmo == r.algoritmo) & (tt.grafo == r.grafo)
               & np.isclose(tt.nivel, r.nivel)]
        ref = float(np.exp(d[f"ln_{r.metrica}"].mean()))
        if len(d) != 50 or not np.isclose(r.valor_plotado, ref, rtol=1e-12, atol=0):
            divs_a.append(f"{r.teste}/{r.metrica}/{r.algoritmo}/{r.grafo}/nível {r.nivel}: "
                          f"plotado {r.valor_plotado!r}, recalculado {ref!r}, n = {len(d)}")
    L.append("## (a) Pontos × `saida/dados_por_terreno_ln.csv`\n")
    L.append(f"- Pontos conferidos: {len(points)} (n = 50 terrenos em cada); tolerância relativa 1e-12.")
    L.append(f"- Divergências: {len(divs_a)}" + ("" if not divs_a else "\n  - " + "\n  - ".join(divs_a)))
    ok_all &= not divs_a

    # (b) Contra o resumo: o resumo não traz a célula por nível; traz a média geométrica por
    #     algoritmo × representação (todos os níveis) e por nível (todos os algoritmos e
    #     representações). No desenho balanceado, ambas são exp(média dos ln) dos pontos
    #     plotados, agregados na dimensão correspondente.
    sm = parse_summary(summary)
    pts = points.assign(ln=np.log(points.valor_plotado))
    divs_b, n_ag, n_lv = [], 0, 0
    for (test, metric, alg, g), d in pts.groupby(["teste", "metrica", "algoritmo", "grafo"]):
        val = float(np.exp(d.ln.mean())) * (1000 if metric == "tempo" else 1)
        ref, tol = sm["alg_grafo"][(test, metric, alg, g)]
        n_ag += 1
        if abs(val - ref) > tol + 1e-9:
            divs_b.append(f"{test}/{metric}/{alg}/{g}: figuras {val:.6g}, resumo {ref} (tol {tol})")
    for (test, metric, lv), d in pts.groupby(["teste", "metrica", "nivel"]):
        val = float(np.exp(d.ln.mean())) * (1000 if metric == "tempo" else 1)
        key = (test, metric, level_label(test, lv))
        ref, tol = sm["nivel"][key]
        n_lv += 1
        if abs(val - ref) > tol + 1e-9:
            divs_b.append(f"{test}/{metric}/nível {key[2]}: figuras {val:.6g}, resumo {ref} (tol {tol})")
    L.append("\n## (b) Pontos × `resumo_resultados.md`\n")
    L.append("O resumo não contém a média geométrica de cada célula por nível. A conferência usa as "
             "duas agregações que ele contém, recalculadas a partir dos pontos plotados "
             "(exp da média dos ln dos pontos), com tolerância de meia unidade da última casa exibida:\n")
    L.append(f"- Algoritmo × representação (4 níveis agregados): {n_ag} valores conferidos "
             f"({len(points)} pontos envolvidos).")
    L.append(f"- Nível (algoritmos × representações agregados): {n_lv} valores conferidos.")
    L.append(f"- Divergências: {len(divs_b)}" + ("" if not divs_b else "\n  - " + "\n  - ".join(divs_b)))
    ok_all &= not divs_b

    by_fig = points.groupby(["teste", "metrica"]).size()
    L.append("\n## Pontos por figura\n")
    L.append("| Figura | Pontos |")
    L.append("|---|---|")
    for (t, m), k in by_fig.items():
        L.append(f"| fig_{t}_{m}.png | {k} |")
    L.append(f"\nResultado: {'sem divergências' if ok_all else 'HÁ DIVERGÊNCIAS'}.")
    out.write_text("\n".join(L) + "\n", encoding="utf-8")
    return ok_all


# ---------------------------------------------------------------------------------------
# Análise auxiliar: A* × Dijkstra e parcela da inicialização
# ---------------------------------------------------------------------------------------

def astar_overhead(data: pd.DataFrame, tt: pd.DataFrame, out_csv: Path, out_md: Path) -> None:
    rows = []
    raw = data[data[COL_ALG].isin(["Dijkstra", "A*"])].copy()
    raw["ln_parcela"] = np.log(raw["tempo_inicializacao"] / raw[COL_TIME])
    share = raw.groupby(["teste", "grafo", COL_ALG, COL_SEED], as_index=False)["ln_parcela"].mean()
    for test in TESTS:
        for g in GRAPHS:
            d = tt[(tt.teste == test) & (tt.grafo == g)]
            dj = d[d.algoritmo == "Dijkstra"].set_index("seed")
            ast = d[d.algoritmo == "A*"].set_index("seed").loc[dj.index]
            row = {"teste": test, "grafo": g, "n_terrenos": len(dj),
                   "razao_mg_tempo_astar_dijkstra": float(np.exp((ast.ln_tempo - dj.ln_tempo).mean())),
                   "razao_mg_expandidos_astar_dijkstra":
                       float(np.exp((ast.ln_expandidos - dj.ln_expandidos).mean()))}
            for alg, tag in (("Dijkstra", "dijkstra"), ("A*", "astar")):
                sh = share[(share.teste == test) & (share.grafo == g) & (share[COL_ALG] == alg)]
                r = raw[(raw.teste == test) & (raw.grafo == g) & (raw[COL_ALG] == alg)]
                ratio = r["tempo_inicializacao"] / r[COL_TIME]
                row[f"parcela_init_mg_{tag}"] = float(np.exp(sh.ln_parcela.mean()))
                row[f"parcela_init_mediana_linhas_{tag}"] = float(ratio.median())
                row[f"parcela_init_min_{tag}"] = float(ratio.min())
                row[f"parcela_init_max_{tag}"] = float(ratio.max())
                row[f"linhas_parcela_maior_1_{tag}"] = int((ratio > 1).sum())
            rows.append(row)
    res = pd.DataFrame(rows)
    res.to_csv(out_csv, index=False)

    L = ["# A* × Dijkstra: razões e parcela da inicialização\n",
         "Gerado por `analise.py`. Só números, sem interpretação.\n",
         "- Razões: média geométrica entre os 200 terrenos de cada teste (4 níveis × 50), da razão "
         "A*/Dijkstra no mesmo terreno; cada terreno usa a média dos ln das duas consultas.",
         "- Parcela da inicialização: `tempo_inicializacao / tempo_busca`, linha a linha dos CSVs "
         "brutos. \"MG\" = média geométrica entre terrenos (média dos ln das duas consultas por "
         "terreno); também a mediana, o mínimo e o máximo das linhas.",
         "- Medição: `tempo_inicializacao` é medido uma vez por terreno e representação, à parte das "
         "buscas (`measureSearchStateInit`, em `include/core/statistics.hpp`); o mesmo valor aparece "
         "nas linhas de todos os algoritmos do terreno. A última coluna conta as linhas com razão > 1.\n",
         "| Teste | Representação | Tempo A*/Dij | Expandidos A*/Dij | Init/busca Dij (MG; mediana; mín–máx) | "
         "Init/busca A* (MG; mediana; mín–máx) | Linhas > 1 (Dij; A*) |",
         "|---|---|---|---|---|---|---|"]
    for _, r in res.iterrows():
        L.append(f"| {TEST_LABEL[r.teste]} | {GRAPH_LABEL[r.grafo]} | {br(r.razao_mg_tempo_astar_dijkstra, 3)} | "
                 f"{br(r.razao_mg_expandidos_astar_dijkstra, 3)} | "
                 f"{br(r.parcela_init_mg_dijkstra, 4)}; {br(r.parcela_init_mediana_linhas_dijkstra, 4)}; "
                 f"{br(r.parcela_init_min_dijkstra, 4)}–{br(r.parcela_init_max_dijkstra, 4)} | "
                 f"{br(r.parcela_init_mg_astar, 4)}; {br(r.parcela_init_mediana_linhas_astar, 4)}; "
                 f"{br(r.parcela_init_min_astar, 4)}–{br(r.parcela_init_max_astar, 4)} | "
                 f"{r.linhas_parcela_maior_1_dijkstra}; {r.linhas_parcela_maior_1_astar} |")
    out_md.write_text("\n".join(L) + "\n", encoding="utf-8")

# ---------------------------------------------------------------------------------------
# Resumo em Markdown (só números, sem interpretação)
# ---------------------------------------------------------------------------------------

def fmt_val(metric: str, x: float) -> str:
    if metric == "tempo":
        return br(x * 1000, 3) + " ms"
    if metric == "custo_relativo":
        return br(x, 4)
    return br(x, 0) if x >= 100 else br(x, 1)


def write_summary(path: Path, results: dict, anova_all: pd.DataFrame, sw_all: pd.DataFrame,
                  tw_all: pd.DataFrame, tl_all: pd.DataFrame, desc: pd.DataFrame) -> None:
    L = []
    L.append("# Resumo dos resultados\n")
    L.append("Gerado por `analise.py`. Só números; sem interpretação. Valores em escala original são "
             "médias geométricas (exp da média dos ln por terreno). Testes F com correção de "
             "Greenhouse-Geisser nos efeitos dentro do terreno; α = 0,05. Tabelas completas em `saida/`.\n")
    L.append("Notação dos efeitos: **N** = nível (entre terrenos), **Alg** = algoritmo, "
             "**Rep** = representação. Razão = razão das médias geométricas (grupo 1 / grupo 2).\n")
    eff_name = {"A": "N", "B": "Alg", "C": "Rep", "A×B": "N × Alg", "A×C": "N × Rep",
                "B×C": "Alg × Rep", "A×B×C": "N × Alg × Rep"}
    for test in TESTS:
        L.append(f"\n## {TEST_LABEL[test]}\n")
        for metric in METRICS:
            gm, levels, algs = results[(test, metric)]
            L.append(f"\n### {METRIC_LABEL[metric]}\n")
            if metric == "custo_relativo":
                L.append("Apenas Weighted A* e Greedy Best-First.\n")
            L.append("Médias geométricas marginais:\n")
            L.append("- Nível: " + "; ".join(f"{level_label(test, lv)} = {fmt_val(metric, v)}"
                                              for lv, v in gm["nivel"].items()))
            L.append("- Algoritmo: " + "; ".join(f"{k} = {fmt_val(metric, v)}" for k, v in gm["algoritmo"].items()))
            L.append("- Representação: " + "; ".join(f"{GRAPH_LABEL[k]} = {fmt_val(metric, v)}"
                                                       for k, v in gm["grafo"].items()))
            L.append("\nMédia geométrica por algoritmo × representação (todos os níveis):\n")
            L.append("| Algoritmo | " + " | ".join(GRAPH_LABEL[g] for g in GRAPHS) + " |")
            L.append("|---|" + "---|" * len(GRAPHS))
            for j, alg in enumerate(algs):
                L.append(f"| {alg} | " + " | ".join(fmt_val(metric, gm["alg_grafo"][j, k])
                                                    for k in range(len(GRAPHS))) + " |")

            a = anova_all[(anova_all.teste == test) & (anova_all.metrica == metric)]
            L.append("\nANOVA split-plot:\n")
            L.append("| Efeito | F | gl (GG) | ε GG | p (GG) | η² parcial |")
            L.append("|---|---|---|---|---|---|")
            for _, r in a.iterrows():
                gl = f"{br(r.gl_GG, 2)}; {br(r.gl_erro_GG, 1)}" if np.isfinite(r.epsilon_GG) \
                    else f"{int(r.gl)}; {int(r.gl_erro)}"
                L.append(f"| {eff_name[r.efeito]} | {br(r.F, 2)} | {gl} | "
                         f"{br(r.epsilon_GG, 3) if np.isfinite(r.epsilon_GG) else '—'} | "
                         f"{br_p(r.p_GG)} | {br(r.eta2_parcial, 3)} |")

            s = sw_all[(sw_all.teste == test) & (sw_all.metrica == metric)]
            L.append("\nShapiro-Wilk dos resíduos: " + "; ".join(
                f"{r.estrato} (n = {r.n}): W = {br(r.W, 3)}, p {('= ' + br(r.p, 3)) if r.p >= 0.001 else '< 0,001'}"
                for _, r in s.iterrows()))

            t = tw_all[(tw_all.teste == test) & (tw_all.metrica == metric)]
            L.append("\nTukey dentro do terreno, representações por algoritmo — razão (p):\n")
            pairs = list(itertools.combinations(GRAPHS, 2))
            L.append("| Algoritmo | " + " | ".join(f"{GRAPH_LABEL[x]} / {GRAPH_LABEL[y]}" for x, y in pairs) + " |")
            L.append("|---|" + "---|" * len(pairs))
            for alg in algs:
                tt_ = t[(t.comparacao == "representações por algoritmo") & (t.fixo == alg)]
                cells = []
                for x, y in pairs:
                    r = tt_[(tt_.grupo_1 == x) & (tt_.grupo_2 == y)].iloc[0]
                    cells.append(f"{br(r.razao_mg, 3)} ({br_p(r.p)})")
                L.append(f"| {alg} | " + " | ".join(cells) + " |")

            L.append("\nTukey dentro do terreno, algoritmos por representação — razão (p):\n")
            apairs = list(itertools.combinations(algs, 2))
            L.append("| Representação | " + " | ".join(f"{x} / {y}" for x, y in apairs) + " |")
            L.append("|---|" + "---|" * len(apairs))
            for g in GRAPHS:
                tt_ = t[(t.comparacao == "algoritmos por representação") & (t.fixo == g)]
                cells = []
                for x, y in apairs:
                    r = tt_[(tt_.grupo_1 == x) & (tt_.grupo_2 == y)].iloc[0]
                    cells.append(f"{br(r.razao_mg, 3)} ({br_p(r.p)})")
                L.append(f"| {GRAPH_LABEL[g]} | " + " | ".join(cells) + " |")

            tl = tl_all[(tl_all.teste == test) & (tl_all.metrica == metric)]
            lo, hi = levels[0], levels[-1]
            L.append(f"\nTukey entre níveis (grupos independentes, n = 50 por nível): para cada "
                     f"algoritmo × representação, razão e p do par extremo "
                     f"{level_label(test, hi)} / {level_label(test, lo)} e número de pares "
                     f"significativos entre os 6 possíveis:\n")
            L.append("| Algoritmo | " + " | ".join(GRAPH_LABEL[g] for g in GRAPHS) + " |")
            L.append("|---|" + "---|" * len(GRAPHS))
            for alg in algs:
                cells = []
                for g in GRAPHS:
                    c_ = tl[(tl.algoritmo == alg) & (tl.grafo == g)]
                    r = c_[(c_.nivel_1 == lo) & (c_.nivel_2 == hi)].iloc[0]
                    cells.append(f"{br(1 / r.razao_mg, 3)} ({br_p(r.p)}); {int(c_.significativo.sum())}/6")
                L.append(f"| {alg} | " + " | ".join(cells) + " |")
    path.write_text("\n".join(L) + "\n", encoding="utf-8")


# ---------------------------------------------------------------------------------------

def main() -> int:
    here = Path(__file__).resolve().parent
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("dados", type=Path, help="pasta da campanha (contém manifest.csv e <teste>_<grafo>/)")
    ap.add_argument("--saida", type=Path, default=here / "saida")
    ap.add_argument("--resumo", type=Path, default=here / "resumo_resultados.md")
    ap.add_argument("--sims", type=int, default=2000, help="simulações da validação (erro tipo I e poder)")
    args = ap.parse_args()

    root = args.dados.resolve()
    out = args.saida
    out.mkdir(parents=True, exist_ok=True)
    chk = Checks()
    chk.lines.append("# Relatório de verificações\n")
    chk.lines.append(f"Dados: `{root.name}`\n")
    chk.lines.append("Versões: " + ", ".join([
        f"Python {sys.version.split()[0]}", f"numpy {np.__version__}", f"pandas {pd.__version__}",
        f"scipy {__import__('scipy').__version__}", f"matplotlib {matplotlib.__version__}",
        f"statsmodels {__import__('statsmodels').__version__} (só na validação)"]) + "\n")

    data = read_campaign(root, chk.lines)
    integrity_checks(root, data, chk)
    manifest_checks(root, chk)

    data_failed = chk.failed
    chk.failed = False
    validate_anova(chk, args.sims)
    if chk.failed:
        # A ANOVA só é aplicada aos dados reais depois de validada.
        (out / "relatorio_verificacoes.md").write_text("\n".join(chk.lines) + "\n", encoding="utf-8")
        print("\nValidação da ANOVA falhou; análise dos dados reais não executada.", file=sys.stderr)
        return 2
    chk.failed = data_failed

    tt = terrain_table(data)
    tt.to_csv(out / "dados_por_terreno_ln.csv", index=False)

    desc = descriptive(tt)
    desc.to_csv(out / "descritiva_mediana_iiq.csv", index=False)

    anovas, sws, tws, tls, results = [], [], [], [], {}
    for test in TESTS:
        for metric in METRICS:
            anova, sw, tw, tl, gm, levels, algs = analyse(tt, test, metric)
            anovas.append(anova)
            sws.append(sw)
            tws.append(tw)
            tls.append(tl)
            results[(test, metric)] = (gm, levels, algs)
            print(f"[ANOVA] {test} / {metric}: ok")
    anova_all = pd.concat(anovas, ignore_index=True)
    sw_all = pd.concat(sws, ignore_index=True)
    tw_all = pd.concat(tws, ignore_index=True)
    tl_all = pd.concat(tls, ignore_index=True)
    anova_all.to_csv(out / "anova_split_plot.csv", index=False)
    sw_all.to_csv(out / "shapiro_wilk.csv", index=False)
    tw_all.to_csv(out / "tukey_dentro_terreno.csv", index=False)
    tl_all.to_csv(out / "tukey_entre_niveis.csv", index=False)

    fig_dir = out / "figuras"
    fig_dir.mkdir(parents=True, exist_ok=True)
    points = []
    for test in TESTS:
        for metric in ("tempo", "expandidos", "custo_relativo"):
            points.append(plot_metric(desc, test, metric, fig_dir / f"fig_{test}_{metric}.png"))
    points = pd.concat(points, ignore_index=True)

    write_summary(args.resumo, results, anova_all, sw_all, tw_all, tl_all, desc)

    figs_ok = verify_figures(points, out / "dados_por_terreno_ln.csv", args.resumo,
                             out / "relatorio_figuras.md")
    print(f"[figuras] {len(points)} pontos conferidos: {'OK' if figs_ok else 'DIVERGÊNCIAS'}")
    astar_overhead(data, tt, out / "a_star_overhead.csv", out / "a_star_overhead.md")
    (out / "relatorio_verificacoes.md").write_text("\n".join(chk.lines) + "\n", encoding="utf-8")
    print(f"\nSaídas em {out}; resumo em {args.resumo}")
    return 1 if (chk.failed or not figs_ok) else 0


if __name__ == "__main__":
    raise SystemExit(main())
