# Use specific version of nvidia cuda image
# FROM wlsdml1114/my-comfy-models:v1 as model_provider
FROM wlsdml1114/multitalk-base:1.8 as runtime

RUN pip install -U "huggingface_hub[hf_transfer]"
RUN pip install runpod websocket-client

WORKDIR /

RUN git clone https://github.com/comfyanonymous/ComfyUI.git && \
    cd /ComfyUI && \
    pip install -r requirements.txt

RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/Comfy-Org/ComfyUI-Manager.git && \
    cd ComfyUI-Manager && \
    pip install -r requirements.txt

RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-KJNodes && \
    cd ComfyUI-KJNodes && \
    pip install -r requirements.txt

RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git

RUN cd /ComfyUI/custom_nodes/ComfyUI-Frame-Interpolation && \
    python install.py
    
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite && \
    cd ComfyUI-VideoHelperSuite && \
    pip install -r requirements.txt

RUN wget -q https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors -O /ComfyUI/models/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors
RUN wget -q https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors -O /ComfyUI/models/vae/wan_2.1_vae.safetensors
RUN wget -q https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors -O /ComfyUI/models/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors
RUN wget -q https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors -O /ComfyUI/models/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors
RUN wget -q https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors -O /ComfyUI/models/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors
RUN wget -q https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors -O /ComfyUI/models/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors

RUN mkdir -p /ComfyUI/custom_nodes/ComfyUI-Frame-Interpolation/ckpts/rife && wget https://huggingface.co/hfmaster/models-moved/resolve/cab6dcee2fbb05e190dbb8f536fbdaa489031a14/rife/rife49.pth -O /ComfyUI/custom_nodes/ComfyUI-Frame-Interpolation/ckpts/rife/rife49.pth


COPY . .
RUN mkdir -p /ComfyUI/user/default/ComfyUI-Manager
COPY config.ini /ComfyUI/user/default/ComfyUI-Manager/config.ini
COPY extra_model_paths.yaml /ComfyUI/extra_model_paths.yaml
RUN chmod +x /entrypoint.sh

# カスタムLoRA 9種類（計18ファイル）を /opt/custom_loras へ保存
RUN mkdir -p /opt/custom_loras /ComfyUI/models/loras && \
    wget -O "/opt/custom_loras/DR34ML4Y_All_In_One_NSFW_high.safetensors" "https://civitai.red/api/download/models/2553151?fileId=2441563&token=c879d68b49e0b217aee0cf61001d03e0" && \
    wget -O "/opt/custom_loras/DR34ML4Y_All_In_One_NSFW_low.safetensors" "https://civitai.red/api/download/models/2553271?fileId=2441662&token=c879d68b49e0b217aee0cf61001d03e0" && \
    wget -O "/opt/custom_loras/Wan_2.2_Close-Up_Facial_Cumshots_high.safetensors" "https://civitai.red/api/download/models/2772088?fileId=2658091&token=c879d68b49e0b217aee0cf61001d03e0" && \
    wget -O "/opt/custom_loras/Wan_2.2_Close-Up_Facial_Cumshots_low.safetensors" "https://civitai.red/api/download/models/2772322?fileId=2658308&token=c879d68b49e0b217aee0cf61001d03e0" && \
    wget -O "/opt/custom_loras/sh00tz_series_of_cumshots_high.safetensors" "https://civitai.red/api/download/models/2731730?fileId=2617810&token=c879d68b49e0b217aee0cf61001d03e0" && \
    wget -O "/opt/custom_loras/sh00tz_series_of_cumshots_low.safetensors" "https://civitai.red/api/download/models/2731744?fileId=2617822&token=c879d68b49e0b217aee0cf61001d03e0" && \
    wget -O "/opt/custom_loras/WAN_2.2_Anime_Cumshot_Aesthetics_high.safetensors" "https://civitai.red/api/download/models/2116008?fileId=2010473&token=c879d68b49e0b217aee0cf61001d03e0" && \
    wget -O "/opt/custom_loras/WAN_2.2_Anime_Cumshot_Aesthetics_low.safetensors" "https://civitai.red/api/download/models/2116027?fileId=2010484&token=c879d68b49e0b217aee0cf61001d03e0" && \
    wget -O "/opt/custom_loras/Deepthroat_Face_Fuck_high.safetensors" "https://civitai.red/api/download/models/2517513?fileId=2405261&token=c879d68b49e0b217aee0cf61001d03e0" && \
    wget -O "/opt/custom_loras/Deepthroat_Face_Fuck_low.safetensors" "https://civitai.red/api/download/models/2517548?fileId=2405303&token=c879d68b49e0b217aee0cf61001d03e0" && \
    wget -O "/opt/custom_loras/Ultimate_DeepThroat_I2V_high.safetensors" "https://civitai.red/api/download/models/2325788?fileId=2215936&token=c879d68b49e0b217aee0cf61001d03e0" && \
    wget -O "/opt/custom_loras/Ultimate_DeepThroat_I2V_low.safetensors" "https://civitai.red/api/download/models/2191446?fileId=2084409&token=c879d68b49e0b217aee0cf61001d03e0" && \
    wget -O "/opt/custom_loras/Deepthroat_Blowjob_Wan_2.X_I2V_high.safetensors" "https://civitai.red/api/download/models/2152516?fileId=2045841&token=c879d68b49e0b217aee0cf61001d03e0" && \
    wget -O "/opt/custom_loras/Deepthroat_Blowjob_Wan_2.X_I2V_low.safetensors" "https://civitai.red/api/download/models/2152583?fileId=2045910&token=c879d68b49e0b217aee0cf61001d03e0" && \
    wget -O "/opt/custom_loras/WAN_2.2_I2V_Combo_Handjob_Blowjob_high.safetensors" "https://civitai.red/api/download/models/2149593?fileId=2043052&token=c879d68b49e0b217aee0cf61001d03e0" && \
    wget -O "/opt/custom_loras/WAN_2.2_I2V_Combo_Handjob_Blowjob_low.safetensors" "https://civitai.red/api/download/models/2149614?fileId=2043063&token=c879d68b49e0b217aee0cf61001d03e0" && \
    wget -O "/opt/custom_loras/Mouthfull_Cumshot_high.safetensors" "https://civitai.red/api/download/models/2430424?fileId=2321108&token=c879d68b49e0b217aee0cf61001d03e0" && \
    wget -O "/opt/custom_loras/Mouthfull_Cumshot_low.safetensors" "https://civitai.red/api/download/models/2430183?fileId=2328548&token=c879d68b49e0b217aee0cf61001d03e0" && \
    ln -sf /opt/custom_loras/*.safetensors /ComfyUI/models/loras/

CMD ["/entrypoint.sh"]
