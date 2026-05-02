<#import "template.ftl" as layout>
<!DOCTYPE html>
<html class="dark" lang="fr">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;800&family=Inter:wght@400;700&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    colors: {
                        'primary': '#b1c7f2',
                        'on-primary': '#193053',
                        'background': '#121414',
                        'surface-container-low': '#1a1c1c',
                        'outline': '#8e9099'
                    }
                }
            }
        }
    </script>
    <style>
        .material-symbols-outlined { font-variation-settings: 'FILL' 1, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
        .luxury-gradient { background: linear-gradient(135deg, #b1c7f2 0%, #001b3d 100%); }
    </style>
</head>

<body class="bg-background text-[#e2e2e2] font-['Inter'] antialiased min-h-screen flex flex-col">
    <header class="fixed top-0 left-0 w-full flex justify-between items-center px-6 h-16 bg-[#121414]/70 backdrop-blur-xl border-b border-[#b1c7f2]/15 z-50">
        <div class="flex items-center gap-4">
            <a href="${url.loginUrl}" class="text-[#b1c7f2]"><span class="material-symbols-outlined">arrow_back</span></a>
            <span class="font-bold text-xs text-[#b1c7f2] uppercase tracking-tighter">INSTITUTIONAL TRANSPORT</span>
        </div>
    </header>

    <main class="flex-grow pt-24 px-6 pb-12 flex flex-col max-w-md mx-auto w-full">
        <section class="mb-10">
            <h1 class="text-3xl font-extrabold tracking-tighter text-primary mb-2 uppercase font-['Manrope']">General Express</h1>
            <p class="text-sm tracking-wide text-[#c4c6cf]">Compte Institutionnel — Inscription</p>
        </section>

        <form action="${url.registrationAction}" method="post" class="space-y-6">
            
            <#if message?exists && message.type == 'error'>
                <div class="bg-red-900/50 border border-red-500 text-red-200 p-3 rounded text-xs">
                    ${kcSanitize(message.summary)?no_esc}
                </div>
            </#if>

            <div class="grid grid-cols-2 gap-4">
                <div class="space-y-2">
                    <label class="block text-[10px] uppercase tracking-widest text-primary font-semibold">Nom</label>
                    <input type="text" name="lastName" value="${(register.formData.lastName!'')}" 
                           class="w-full bg-surface-container-low border-none focus:ring-1 focus:ring-primary text-white text-sm py-4 px-4 rounded-sm" />
                </div>
                <div class="space-y-2">
                    <label class="block text-[10px] uppercase tracking-widest text-primary font-semibold">Prénom</label>
                    <input type="text" name="firstName" value="${(register.formData.firstName!'')}" 
                           class="w-full bg-surface-container-low border-none focus:ring-1 focus:ring-primary text-white text-sm py-4 px-4 rounded-sm" />
                </div>
            </div>

            <div class="space-y-2">
                <label class="block text-[10px] uppercase tracking-widest text-primary font-semibold">Nom d'utilisateur</label>
                <input type="text" name="username" value="${(register.formData.username!'')}" 
                       class="w-full bg-surface-container-low border-none focus:ring-1 focus:ring-primary text-white text-sm py-4 px-4 rounded-sm" />
            </div>

            <div class="space-y-2">
                <label class="block text-[10px] uppercase tracking-widest text-primary font-semibold">Adresse Email</label>
                <input type="email" name="email" value="${(register.formData.email!'')}" 
                       class="w-full bg-surface-container-low border-none focus:ring-1 focus:ring-primary text-white text-sm py-4 px-4 rounded-sm" />
            </div>

            <div class="space-y-2">
                <label class="block text-[10px] uppercase tracking-widest text-primary font-semibold">Mot de passe</label>
                <input type="password" name="password" 
                       class="w-full bg-surface-container-low border-none focus:ring-1 focus:ring-primary text-white text-sm py-4 px-4 rounded-sm" />
            </div>

            <div class="space-y-2">
                <label class="block text-[10px] uppercase tracking-widest text-primary font-semibold">Confirmer le mot de passe</label>
                <input type="password" name="password-confirm" 
                       class="w-full bg-surface-container-low border-none focus:ring-1 focus:ring-primary text-white text-sm py-4 px-4 rounded-sm" />
            </div>

            <div class="pt-6">
                <button type="submit" class="w-full luxury-gradient text-white font-bold py-5 rounded-sm uppercase tracking-widest text-xs shadow-lg active:scale-[0.98] transition-transform">
                    Finaliser l'inscription
                </button>
            </div>
        </form>

        <footer class="mt-auto py-8 text-center border-t border-white/10">
            <div class="flex items-center justify-center gap-2 mb-4">
                <span class="material-symbols-outlined text-primary text-sm">verified_user</span>
                <span class="text-[9px] uppercase tracking-widest text-[#c4c6cf] font-bold">Protocole de Sécurité Institutionnel</span>
            </div>
            <p class="text-[8px] text-outline uppercase">
                Vos données sont protégées par un cryptage de niveau terminal.
            </p>
        </footer>
    </main>
</body>
</html>