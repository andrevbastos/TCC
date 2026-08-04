import tkinter as tk
import socket
import random
import os

# Endereço de destino UDP
UDP_IP = "127.0.0.1"
UDP_PORT = 12345

# Converte string hexadecimal (#ffffff) para floats RGB (0.0 a 1.0)
def hex_to_rgb_floats(hex_str):
    hex_str = hex_str.lstrip('#')
    r = int(hex_str[0:2], 16) / 255.0
    g = int(hex_str[2:4], 16) / 255.0
    b = int(hex_str[4:6], 16) / 255.0
    return r, g, b

class TerrainControlsApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Controle de Terrenos")
        self.root.geometry("420x840") # Ajustado para o layout compacto sem presets
        self.root.configure(bg="#0b0b0c")
        self.root.resizable(False, False)
        
        # Socket UDP
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        
        # Variáveis de Controle
        self.var_width = tk.IntVar(value=256)
        self.var_wave = tk.DoubleVar(value=100.0)
        self.var_freq = tk.DoubleVar(value=4.0)
        self.var_amp = tk.DoubleVar(value=1.0)
        self.var_exp = tk.DoubleVar(value=1.0)
        self.var_seed = tk.IntVar(value=42)
        self.var_octaves = tk.IntVar(value=3)
        self.var_intensity = tk.DoubleVar(value=100.0)
        
        # Cor padrão inicial (Verde Oliva)
        self.current_color = "#4caf50"
        
        # Caminho da imagem temporária do preview
        self.preview_path = "build/noise_preview.png"
        self.zoomed_photo = None
        
        self.palette_canvas_list = []
        
        self.setup_ui()
        self.send_parameters() # Envia os valores iniciais
        
        # Inicia a escuta/leitura periódica da imagem de preview gerada pelo C++
        self.poll_preview()
        
    def setup_ui(self):
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        
        # Painel central de controles
        self.center_frame = tk.Frame(self.root, bg="#0b0b0c")
        self.center_frame.grid(row=0, column=0, padx=20, pady=20, sticky="")
        
        # Título
        title_label = tk.Label(
            self.center_frame, 
            text="G E R A D O R  D E  T E R R E N O S", 
            font=("Helvetica", 10, "bold"), 
            bg="#0b0b0c", 
            fg="#ffffff"
        )
        title_label.pack(pady=(0, 20))
        
        # Sliders
        self.create_slider(self.center_frame, "Resolução do Grid", self.var_width, 64, 512, is_int=True)
        self.create_slider(self.center_frame, "Comprimento de Onda", self.var_wave, 10, 500)
        self.create_slider(self.center_frame, "Frequência", self.var_freq, 0.1, 10.0)
        self.create_slider(self.center_frame, "Amplitude", self.var_amp, 0.1, 2.0)
        self.create_slider(self.center_frame, "Expoente", self.var_exp, 0.5, 4.0)
        self.create_slider(self.center_frame, "Oitavas", self.var_octaves, 1, 8, is_int=True)
        self.create_slider(self.center_frame, "Intensidade Vertical", self.var_intensity, 10, 300)
        
        # Separador 1
        separator = tk.Frame(self.center_frame, height=1, bg="#1a1a1e")
        separator.pack(fill=tk.X, pady=12)
        
        # Seed e Reseed
        seed_frame = tk.Frame(self.center_frame, bg="#0b0b0c")
        seed_frame.pack(fill=tk.X)
        
        seed_label = tk.Label(
            seed_frame, 
            text="SEED:", 
            font=("Helvetica", 8, "bold"), 
            bg="#0b0b0c", 
            fg="#808085"
        )
        seed_label.pack(side=tk.LEFT)
        
        self.seed_entry = tk.Entry(
            seed_frame, 
            textvariable=self.var_seed, 
            width=10, 
            font=("Helvetica", 9), 
            bg="#16161a", 
            fg="#ffffff", 
            insertbackground="#ffffff",
            relief=tk.FLAT,
            bd=4
        )
        self.seed_entry.pack(side=tk.LEFT, padx=10)
        self.seed_entry.bind("<KeyRelease>", lambda e: self.send_parameters())
        
        reseed_btn = tk.Button(
            seed_frame, 
            text="RESEED", 
            command=self.reseed, 
            bg="#ffffff", 
            fg="#0b0b0c", 
            activebackground="#e0e0e6", 
            activeforeground="#0b0b0c",
            font=("Helvetica", 8, "bold"),
            relief=tk.FLAT,
            bd=0,
            padx=14,
            pady=5,
            cursor="hand2"
        )
        reseed_btn.pack(side=tk.RIGHT)
        
        # Separador 2
        separator2 = tk.Frame(self.center_frame, height=1, bg="#1a1a1e")
        separator2.pack(fill=tk.X, pady=12)
        
        # --- Fileira de Cores Livres no Rodapé ---
        palette_label = tk.Label(
            self.center_frame, 
            text="PALETA DE CORES", 
            font=("Helvetica", 7, "bold"), 
            bg="#0b0b0c", 
            fg="#808085"
        )
        palette_label.pack(pady=(0, 5))
        
        palette_frame = tk.Frame(self.center_frame, bg="#0b0b0c")
        palette_frame.pack(pady=3)
        
        # Cores predefinidas para a paleta rápida
        palette_colors = ["#4caf50", "#735135", "#e6e6f2", "#0091ea", "#2e7d32"]
        
        for hex_color in palette_colors:
            color_btn = tk.Canvas(
                palette_frame, 
                width=20, 
                height=20, 
                bg="#0b0b0c", 
                highlightthickness=0, 
                cursor="hand2"
            )
            color_btn.pack(side=tk.LEFT, padx=8)
            # Desenha um círculo preenchido
            color_btn.create_oval(2, 2, 18, 18, fill=hex_color, outline="#2a2a30", width=1, tags="circle")
            
            # Bind de clique
            color_btn.bind("<Button-1>", lambda e, c=hex_color: self.select_color(c))
            self.palette_canvas_list.append((hex_color, color_btn))
            
        # Label do Título do Preview
        preview_title = tk.Label(
            self.center_frame, 
            text="PREVIEW DO RUÍDO", 
            font=("Helvetica", 7, "bold"), 
            bg="#0b0b0c", 
            fg="#808085"
        )
        preview_title.pack(pady=(12, 5))
        
        # Container de Imagem do Preview com borda fina
        preview_border = tk.Frame(self.center_frame, bg="#1a1a1e", padx=1, pady=1)
        preview_border.pack(pady=5)
        
        self.preview_label = tk.Label(
            preview_border, 
            text="Aguardando render...",
            font=("Helvetica", 8),
            bg="#0b0b0c", 
            fg="#808085",
            width=36,
            height=12
        )
        self.preview_label.pack()
        
        # Destaca a cor inicial (Verde Oliva)
        self.highlight_color("#4caf50")
        
    def create_slider(self, parent, label_text, var, from_val, to_val, is_int=False):
        frame = tk.Frame(parent, bg="#0b0b0c")
        frame.pack(fill=tk.X, pady=5)
        
        label_frame = tk.Frame(frame, bg="#0b0b0c")
        label_frame.pack(fill=tk.X)
        
        title = tk.Label(
            label_frame, 
            text=label_text.upper(), 
            font=("Helvetica", 7, "bold"), 
            bg="#0b0b0c", 
            fg="#808085"
        )
        title.pack(side=tk.LEFT)
        
        val_label = tk.Label(
            label_frame, 
            text="", 
            font=("Helvetica", 8, "bold"), 
            bg="#0b0b0c", 
            fg="#ffffff"
        )
        val_label.pack(side=tk.RIGHT)
        
        def update_val(val):
            formatted_val = f"{int(float(val))}" if is_int else f"{float(val):.2f}"
            val_label.config(text=formatted_val)
            self.send_parameters()
            
        slider = tk.Scale(
            frame, 
            from_=from_val, 
            to=to_val, 
            orient=tk.HORIZONTAL, 
            variable=var, 
            resolution=1 if is_int else 0.05,
            showvalue=False,
            bg="#16161a",
            fg="#ffffff",
            highlightthickness=0,
            troughcolor="#16161a",
            activebackground="#ffffff",
            command=update_val,
            relief=tk.FLAT,
            bd=0,
            length=350,
            sliderlength=14
        )
        slider.pack(fill=tk.X, pady=(2, 0))
        
        initial_val = var.get()
        val_label.config(text=f"{initial_val}" if is_int else f"{initial_val:.2f}")

    def reseed(self):
        new_seed = random.randint(0, 999999)
        self.var_seed.set(new_seed)
        self.send_parameters()
                
    def select_color(self, hex_color):
        self.current_color = hex_color
        self.highlight_color(hex_color)
        self.send_parameters()

    def highlight_color(self, active_hex):
        for hex_color, canvas in self.palette_canvas_list:
            canvas.delete("border")
            if hex_color == active_hex:
                # Desenha uma borda branca de destaque ao redor do círculo ativo
                canvas.create_oval(1, 1, 19, 19, outline="#ffffff", width=1.5, tags="border")

    def poll_preview(self):
        if os.path.exists(self.preview_path):
            try:
                # Carrega o PNG de tamanho fixo 256x256 salvo pelo C++
                photo = tk.PhotoImage(file=self.preview_path)
                
                # Exibe a imagem de tamanho constante
                self.preview_label.config(image=photo, text="", width=0, height=0)
                self.zoomed_photo = photo # Mantém a referência na memória
            except Exception:
                pass
                
        # Agenda a próxima verificação para dali 80ms
        self.root.after(80, self.poll_preview)

    def send_parameters(self):
        try:
            seed_val = self.var_seed.get()
        except tk.TclError:
            return

        w = self.var_width.get()
        h = w
        wave = self.var_wave.get()
        freq = self.var_freq.get()
        amp = self.var_amp.get()
        exp = self.var_exp.get()
        seed = seed_val
        octaves = self.var_octaves.get()
        intensity = self.var_intensity.get()
        
        # Converte a cor hexadecimal atual em floats R, G, B
        r, g, b = hex_to_rgb_floats(self.current_color)
        
        # Envia parâmetros ao C++ com cor R, G, B no fim
        msg = f"{w} {h} {wave:.4f} {freq:.4f} {amp:.4f} {exp:.4f} {seed} {octaves} {intensity:.4f} {r:.3f} {g:.3f} {b:.3f}"
        try:
            self.sock.sendto(msg.encode(), (UDP_IP, UDP_PORT))
        except Exception:
            pass

if __name__ == "__main__":
    root = tk.Tk()
    app = TerrainControlsApp(root)
    root.mainloop()
