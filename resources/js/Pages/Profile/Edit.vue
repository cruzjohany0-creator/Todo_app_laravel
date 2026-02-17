<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import DeleteUserForm from './Partials/DeleteUserForm.vue';
import UpdatePasswordForm from './Partials/UpdatePasswordForm.vue';
import UpdateProfileInformationForm from './Partials/UpdateProfileInformationForm.vue';
import { Head } from '@inertiajs/vue3';

defineProps({
    mustVerifyEmail: {
        type: Boolean,
    },
    status: {
        type: String,
    },
});
</script>

<template>
    <Head title="Perfil del Sistema" />

    <AuthenticatedLayout>
        <template #header>
            <h2 class="text-2xl font-black leading-tight text-white tracking-tighter uppercase italic">
                <span class="text-cyan-400 mr-2"></span>Configuración Usuario
            </h2>
        </template>

        <div class="py-12 relative overflow-hidden">
            <div class="mx-auto max-w-7xl space-y-8 sm:px-6 lg:px-8">
                
                <div class="cyber-section-card group">
                    <div class="section-glow-bar bg-cyan-500 shadow-[0_0_15px_#06b6d4]"></div>
                    <div class="p-4 sm:p-8 relative z-10">
                        <UpdateProfileInformationForm
                            :must-verify-email="mustVerifyEmail"
                            :status="status"
                            class="max-w-xl cyber-form-content"
                        />
                    </div>
                </div>

                <div class="cyber-section-card group">
                    <div class="section-glow-bar bg-blue-600 shadow-[0_0_15px_#2563eb]"></div>
                    <div class="p-4 sm:p-8 relative z-10">
                        <UpdatePasswordForm class="max-w-xl cyber-form-content" />
                    </div>
                </div>

                <div class="cyber-section-card group border-red-900/30">
                    <div class="section-glow-bar bg-red-600 shadow-[0_0_15px_#dc2626]"></div>
                    <div class="p-4 sm:p-8 relative z-10">
                        <DeleteUserForm class="max-w-xl cyber-form-content" />
                    </div>
                </div>

            </div>
        </div>
    </AuthenticatedLayout>
</template>

<style scoped>
/* Contenedor tipo Cristal Oscuro igual que las Tareas */
.cyber-section-card {
    position: relative;
    background: rgba(10, 15, 25, 0.85); /* Fondo oscuro profundo */
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 16px;
    transition: all 0.4s ease;
    overflow: hidden;
}

.cyber-section-card:hover {
    border-color: rgba(255, 255, 255, 0.2);
    box-shadow: 0 10px 30px -10px rgba(0, 0, 0, 0.7);
    transform: translateY(-2px);
}

/* Barra lateral estética */
.section-glow-bar {
    position: absolute;
    left: 0;
    top: 0;
    bottom: 0;
    width: 4px;
    opacity: 0.8;
}

/* Ajustes para los textos dentro de los formularios */
:deep(h2) {
    color: #ffffff !important;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: -0.02em;
}

:deep(p) {
    color: #94a3b8 !important; /* Gris azulado para descripciones */
    font-size: 0.9rem;
}

:deep(label) {
    color: #cbd5e1 !important; /* Color de labels de input */
    font-weight: 600;
    text-transform: uppercase;
    font-size: 0.75rem;
}

/* Forzar que los inputs hereden el estilo si no están en componentes separados */
:deep(input) {
    background: rgba(0, 0, 0, 0.4) !important;
    border: 1px solid rgba(255, 255, 255, 0.1) !important;
    color: white !important;
    border-radius: 8px !important;
}

:deep(input:focus) {
    border-color: #06b6d4 !important;
    box-shadow: 0 0 10px rgba(6, 182, 212, 0.3) !important;
}
</style>