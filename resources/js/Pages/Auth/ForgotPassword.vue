<script setup>
import GuestLayout from '@/Layouts/GuestLayout.vue';
import InputError from '@/Components/InputError.vue';
import InputLabel from '@/Components/InputLabel.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import TextInput from '@/Components/TextInput.vue';
import { Head, useForm } from '@inertiajs/vue3';

defineProps({
    status: {
        type: String,
    },
});

const form = useForm({
    email: '',
});

const submit = () => {
    form.post(route('password.email'));
};
</script>

<template>
    <GuestLayout>
        <Head title="Acceso de Recuperación" />

        <div class="cyber-card">
            <div class="corner-tl"></div>
            <div class="corner-br"></div>

            <div class="relative z-10 p-2">
                <div class="mb-8 relative">
                    <h1 class="cyber-title">
                        SISTEMA DE RECUPERACIÓN
                        <span class="block text-xs font-mono text-cyan-500/70 tracking-[0.3em]">AUTH_PROTOCOL: V.2.0.6</span>
                    </h1>
                    <div class="scan-line"></div>
                </div>

                <div class="info-box mb-8">
                    <div class="flex gap-3 items-start">
                        <div class="p-2 bg-cyan-500/20 rounded border border-cyan-500/50">
                            <svg class="w-5 h-5 text-cyan-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m0 0v2m0-2h2m-2 0H10m11-3V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2h14a2 2 0 002-2zm-7-3a3 3 0 110-6 3 3 0 010 6z" />
                            </svg>
                        </div>
                        <p class="text-xs text-slate-400 font-mono leading-relaxed">
                            <span class="text-white font-bold">REQUISITO:</span> Ingrese su terminal de enlace (Email) para autorizar el reenvío de credenciales encriptadas al host de destino.
                        </p>
                    </div>
                </div>

                <div v-if="status" class="status-alert">
                    <span class="mr-2">●</span> {{ status }}
                </div>

                <form @submit.prevent="submit" class="space-y-8">
                    <div class="relative">
                        <InputLabel for="email" value="CANAL DE COMUNICACIÓN (EMAIL)" class="label-tech" />
                        
                        <div class="input-wrapper">
                            <TextInput
                                id="email"
                                type="email"
                                class="mt-1 block w-full input-tech"
                                v-model="form.email"
                                required
                                autofocus
                                autocomplete="username"
                                placeholder="ID_USUARIO@SECTOR.NET"
                            />
                            <div class="input-glow"></div>
                        </div>

                        <InputError class="mt-2 text-[10px] uppercase font-bold" :message="form.errors.email" />
                    </div>

                    <div class="flex flex-col gap-4">
                        <PrimaryButton
                            class="btn-tech"
                            :class="{ 'opacity-50 pointer-events-none': form.processing }"
                            :disabled="form.processing"
                        >
                            <span class="btn-text">INICIAR PROTOCOLO DE RESETEO</span>
                            <div class="btn-glitch"></div>
                        </PrimaryButton>
                        
                        <a :href="route('login')" class="text-center text-[10px] text-cyan-500/50 hover:text-cyan-400 transition-all font-mono tracking-widest uppercase">
                             &lt; Volver al Login_
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </GuestLayout>
</template>

<style scoped>
/* Contenedor Principal Cyberpunk */
.cyber-card {
    position: relative;
    background: linear-gradient(135deg, rgba(15, 23, 42, 0.95) 0%, rgba(2, 6, 23, 0.98) 100%);
    border: 1px solid rgba(6, 182, 212, 0.2);
    padding: 2.5rem;
    box-shadow: 0 0 50px rgba(0, 0, 0, 0.8), inset 0 0 20px rgba(6, 182, 212, 0.05);
}

/* Esquinas decorativas estilo HUD */
.corner-tl { position: absolute; top: -2px; left: -2px; width: 20px; height: 20px; border-top: 3px solid #06b6d4; border-left: 3px solid #06b6d4; }
.corner-br { position: absolute; bottom: -2px; right: -2px; width: 20px; height: 20px; border-bottom: 3px solid #06b6d4; border-right: 3px solid #06b6d4; }

.cyber-title {
    color: #fff;
    font-weight: 900;
    font-size: 1.5rem;
    letter-spacing: -0.05em;
    text-shadow: 0 0 10px rgba(255, 255, 255, 0.2);
}

/* Línea de escaneo animada */
.scan-line {
    position: absolute;
    bottom: -10px;
    left: 0;
    width: 100%;
    height: 1px;
    background: #06b6d4;
    box-shadow: 0 0 15px #06b6d4;
    animation: scan 3s infinite linear;
}

@keyframes scan {
    0% { transform: scaleX(0); opacity: 0; }
    50% { transform: scaleX(1); opacity: 1; }
    100% { transform: scaleX(0); opacity: 0; }
}

.info-box {
    background: rgba(255, 255, 255, 0.03);
    border-left: 2px solid #06b6d4;
    padding: 1rem;
}

.status-alert {
    background: rgba(34, 197, 94, 0.1);
    border: 1px solid rgba(34, 197, 94, 0.3);
    color: #4ade80;
    padding: 0.75rem;
    font-size: 0.75rem;
    font-family: monospace;
    font-weight: bold;
    text-transform: uppercase;
}

/* Inputs de tecnología */
.label-tech {
    color: #94a3b8 !important;
    font-size: 0.65rem !important;
    font-family: monospace;
    letter-spacing: 0.2em;
    margin-bottom: 0.5rem;
}

.input-tech {
    background: rgba(0, 0, 0, 0.5) !important;
    border: 1px solid #1e293b !important;
    color: #22d3ee !important;
    font-family: monospace !important;
    font-size: 0.9rem !important;
    padding: 0.8rem 1rem !important;
    border-radius: 0 !important;
    clip-path: polygon(0% 0%, 100% 0%, 100% 90%, 95% 100%, 0% 100%);
}

.input-tech:focus {
    border-color: #06b6d4 !important;
    box-shadow: 0 0 20px rgba(6, 182, 212, 0.2) !important;
}

/* Botón Maestro */
.btn-tech {
    background: #06b6d4 !important;
    color: #000 !important;
    font-weight: 900 !important;
    text-transform: uppercase !important;
    font-family: monospace !important;
    padding: 1.2rem !important;
    letter-spacing: 0.1em !important;
    border-radius: 0 !important;
    clip-path: polygon(5% 0%, 100% 0%, 100% 70%, 95% 100%, 0% 100%, 0% 30%);
    transition: 0.3s !important;
    border: none !important;
}

.btn-tech:hover {
    filter: brightness(1.2);
    box-shadow: 0 0 30px rgba(6, 182, 212, 0.5);
    transform: scale(1.02);
}

.btn-text { position: relative; z-index: 5; }
</style>