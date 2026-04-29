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
                        'surface-container-lowest': '#0c0f0f',
                        'outline': '#8e9099'
                    }
                }
            }
        }
    </script>
    <style>
        .material-symbols-outlined { font-variation-settings: 'FILL' 1, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
        body { background-color: #121414; }
    </style>
</head>

<body class="bg-background text-[#e2e2e2] font-['Inter'] min-h-screen flex flex-col">
    <header class="fixed top-0 left-0 w-full flex justify-between items-center px-6 h-16 bg-[#121414]/70 backdrop-blur-xl border-b border-[#b1c7f2]/15 z-50">
        <div class="flex items-center gap-4">
            <span class="material-symbols-outlined text-[#b1c7f2]">shield_person</span>
            <h1 class="font-['Manrope'] font-extrabold tracking-tighter text-[#b1c7f2] text-xs uppercase">INSTITUTIONAL ID SYSTEM</h1>
        </div>
    </header>

    <main class="flex-grow flex flex-col pt-24 px-6 pb-12 items-center justify-center">
        <div class="mb-10 text-center">
            <h2 class="font-['Manrope'] text-3xl font-extrabold tracking-tighter text-white mb-2">GENERAL EXPRESS</h2>
            <p class="text-sm tracking-wide uppercase text-[#c4c6cf]">Accès Sécurisé Client</p>
        </div>

        <div class="bg-surface-container-low rounded-lg p-6 shadow-2xl w-full max-w-md border border-white/5">
            <form id="kc-form-login" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post" class="space-y-6">
                
                <#-- Affichage des erreurs Keycloak -->
                <#if message?exists && message.type == 'error'>
                    <div class="bg-red-900/50 border border-red-500 text-red-200 p-3 rounded text-xs mb-4">
                        ${kcSanitize(message.summary)?no_esc}
                    </div>
                </#if>

                <div class="space-y-1">
                    <label for="username" class="text-[10px] font-bold text-primary uppercase tracking-widest ml-1">Identifiant</label>
                    <div class="relative">
                        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                            <span class="material-symbols-outlined text-outline text-lg">alternate_email</span>
                        </div>
                        <input id="username" name="username" value="${(login.username!'')}" type="text" autocomplete="off"
                               class="w-full bg-surface-container-lowest border-none focus:ring-1 focus:ring-primary text-white py-4 pl-11 rounded-sm text-sm" 
                               placeholder="Email ou nom d'utilisateur"/>
                    </div>
                </div>

                <div class="space-y-1">
                    <div class="flex justify-between items-center px-1">
                        <label for="password" class="text-[10px] font-bold text-primary uppercase tracking-widest">Mot de passe</label>
                        <#if realm.resetPasswordAllowed>
                            <a class="text-[10px] text-outline hover:text-primary uppercase" href="${url.loginResetCredentialsUrl}">Oublié ?</a>
                        </#if>
                    </div>
                    <div class="relative">
                        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                            <span class="material-symbols-outlined text-outline text-lg">lock</span>
                        </div>
                        <input id="password" name="password" type="password" autocomplete="off"
                               class="w-full bg-surface-container-lowest border-none focus:ring-1 focus:ring-primary text-white py-4 pl-11 rounded-sm text-sm" 
                               placeholder="••••••••"/>
                    </div>
                </div>

                <button class="w-full bg-primary text-on-primary font-bold py-4 rounded-sm tracking-tight text-base active:opacity-80 transition-opacity flex justify-center items-center gap-2" 
                        name="login" id="kc-login" type="submit">
                    AUTHENTICATE
                    <span class="material-symbols-outlined text-xl">login</span>
                </button>
            </form>

            <#-- Social Providers (Google) -->
            <#if realm.password && social.providers??>
                <div class="flex items-center my-8">
                    <div class="flex-grow h-px bg-white/10"></div>
                    <span class="mx-4 text-[10px] text-outline/40 uppercase tracking-widest">OU</span>
                    <div class="flex-grow h-px bg-white/10"></div>
                </div>
                <div class="space-y-4">
                    <#list social.providers as p>
                        <a href="${p.loginUrl}" class="w-full bg-[#282a2b] text-white font-semibold py-4 rounded-sm border border-white/5 flex justify-center items-center gap-3 text-sm">
                           <span>Continuer avec ${p.displayName}</span>
                        </a>
                    </#list>
                </div>
            </#if>
        </div>

        <footer class="mt-12 text-center">
            <p class="text-[10px] text-outline/30 uppercase tracking-[0.3em]">ADV SECURE GATEWAY V4.2</p>
        </footer>
    </main>
</body>
</html>