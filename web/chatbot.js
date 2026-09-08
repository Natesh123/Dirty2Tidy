document.addEventListener('DOMContentLoaded', () => {
    const fab = document.getElementById('chatbot-fab');
    const windowEl = document.getElementById('chatbot-window');
    const msgContainer = document.getElementById('chatbot-messages');
    const input = document.getElementById('chatbot-input');
    const sendBtn = document.getElementById('chatbot-send');
    const closeBtn = document.getElementById('chatbot-close');

    let isFirstOpen = true;
    let isWaitingForEmail = true;
    let currentEmail = null;
    let currentUserId = null;
    let isNewCustomer = false;
    
    // Strict check that requires the website's active login token
    function checkExistingAuth() {
        try {
            // 1. Check if there is an active login token from the main site
            let isLoggedIn = false;
            if (localStorage.getItem('flutter.demand_token') || sessionStorage.getItem('flutter.demand_token')) {
                isLoggedIn = true;
            } else if (localStorage.getItem('demand_token') || sessionStorage.getItem('demand_token')) {
                isLoggedIn = true;
            }

            // 2. Only bypass email collection if they are ACTIVELY LOGGED IN
            if (isLoggedIn) {
                const scanStorage = (storage, storageName) => {
                    for (let i = 0; i < storage.length; i++) {
                        const key = storage.key(i);
                        let value = storage.getItem(key);
                        
                        if (!value) continue;
                        
                        // Skip technical/marketing keys that might contain support emails
                        const kLower = key.toLowerCase();
                        if (kLower.includes('config') || kLower.includes('setting') || kLower.includes('guest') || kLower.includes('business')) continue;

                        // Flutter plugin prefix stripping
                        if (value.startsWith('String,')) value = value.substring(7);

                        // Extract any email address straight from the raw string
                        const matches = value.match(/([a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/gi);
                        
                        if (matches && matches.length > 0) {
                            for (const match of matches) {
                                const emailStr = match.toLowerCase();
                                // Discard company test or support emails
                                if (!emailStr.includes('support@') && !emailStr.includes('hello@') && !emailStr.includes('info@') && !emailStr.includes('admin@') && !emailStr.includes('example.com') && !emailStr.includes('test.com')) {
                                    currentEmail = emailStr;
                                    isWaitingForEmail = false;
                                    console.log(`Chatbot: Logged in user detected via token. Email [${currentEmail}] found in ${storageName} key [${key}]`);
                                    return true;
                                }
                            }
                        }
                    }
                    return false;
                };

                if (scanStorage(localStorage, 'localStorage')) return;
                if (scanStorage(sessionStorage, 'sessionStorage')) return;
            } else {
                // NOT logged in. Must clear cache and ask for email.
                isWaitingForEmail = true;
                currentEmail = null;
                localStorage.removeItem('chatbot_user_email');
            }
        } catch (e) { console.warn("Chatbot: Error checking auth state", e); }
    }

    checkExistingAuth();
    
    // Track session
    let sessionId = localStorage.getItem('chatbot_session_id');
    if (!sessionId) {
        sessionId = 'sess_' + Math.random().toString(36).substr(2, 9) + Date.now();
        localStorage.setItem('chatbot_session_id', sessionId);
    }

    fab.addEventListener('click', () => {
        windowEl.classList.add('active');
        if (isFirstOpen) {
            startConversation();
            isFirstOpen = false;
        }
    });

    closeBtn.addEventListener('click', () => { windowEl.classList.remove('active'); });

    const sendMessage = () => {
        const text = input.value.trim();
        if (!text) return;
        addMessage(text, 'user');
        input.value = '';
        setTimeout(() => processBotResponse(text), 600);
    };

    sendBtn.addEventListener('click', sendMessage);
    input.addEventListener('keypress', (e) => { if (e.key === 'Enter') sendMessage(); });

    function addMessage(text, side, delay = 0) {
        if (delay > 0) {
            showTypingIndicator();
            setTimeout(() => { hideTypingIndicator(); renderMessage(text, side); }, delay);
        } else {
            renderMessage(text, side);
        }
    }

    function renderMessage(text, side) {
        const msgDiv = document.createElement('div');
        msgDiv.className = `chatbot-msg ${side}`;
        msgDiv.innerHTML = text.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>'); 
        msgContainer.appendChild(msgDiv);
        msgContainer.scrollTo({ top: msgContainer.scrollHeight, behavior: 'smooth' });

        // Save to DB
        saveMessageToDB(text, side);
    }

    async function saveMessageToDB(text, side) {
        try {
            await fetch('https://app.dirt2tidy.com.au/api/v1/chatbot/save-message', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    session_id: sessionId,
                    message: text,
                    sender: side,
                    email: currentEmail,
                    user_id: currentUserId,
                    is_new_customer: isNewCustomer
                })
            });
        } catch (e) { console.warn("Failed to save chat log"); }
    }

    function showTypingIndicator() {
        const indicator = document.createElement('div');
        indicator.className = 'chatbot-typing';
        indicator.id = 'cb-typing-indicator';
        indicator.innerHTML = '<div class="dot"></div><div class="dot"></div><div class="dot"></div>';
        msgContainer.appendChild(indicator);
        msgContainer.scrollTo({ top: msgContainer.scrollHeight, behavior: 'smooth' });
    }

    function hideTypingIndicator() {
        const indicator = document.getElementById('cb-typing-indicator');
        if (indicator) indicator.remove();
    }

    function startConversation() {
        if (!isWaitingForEmail) {
            addMessage(`Hi! 👋 Welcome back to **Dirt2Tidy**.`, 'bot', 400);
            setTimeout(() => {
                addMessage(`How can I help you today?`, 'bot', 600);
                setTimeout(() => showMainOptions(), 800);
            }, 800);
        } else {
            addMessage("Hi! 👋 Welcome to **Dirt2Tidy**.", 'bot', 400);
            setTimeout(() => {
                addMessage("To better assist you, please provide your **email address** first. We'll use this to set up your account and to serve you better way.", 'bot', 600);
            }, 800);
        }
    }

    function showMainOptions() {
        addQuickReplies(["✨ Service List", "💰 View Pricing", "📍 Areas", "📅 Book Now"]);
    }

    function addQuickReplies(replies) {
        const qrContainer = document.createElement('div');
        qrContainer.className = 'chatbot-quick-replies';
        replies.forEach(reply => {
            const btn = document.createElement('button');
            btn.className = 'cb-qr-btn';
            btn.innerText = reply;
            btn.onclick = () => {
                addMessage(reply, 'user');
                processBotResponse(reply);
                qrContainer.remove();
            };
            qrContainer.appendChild(btn);
        });
        msgContainer.appendChild(qrContainer);
        msgContainer.scrollTo({ top: msgContainer.scrollHeight, behavior: 'smooth' });
    }

    // ALL 15 CATEGORY LINKS (SCRAPED FROM LIVE SITE)
    const categoryLinks = {
        "end of lease": "/web/category-service-form?categoryId=5eecf6f9-00d6-4d00-958b-e6804d89ad88",
        "carpet steam": "/web/category-service-form?categoryId=6732c9a5-f2bf-46bb-af57-7bb94b9419a3",
        "spring cleaning": "/web/category-service-form?categoryId=a7cc829f-352d-496e-840b-05193e1fc9a2",
        "office cleaning": "/web/category-service-form?categoryId=4c7cd24d-f3a2-480b-8c3f-f115bc6dd242",
        "oven cleaning": "/web/category-service-form?categoryId=dd556a6e-8175-45aa-8ec4-accc93913785",
        "bbq cleaning": "/web/category-service-form?categoryId=12723afe-78a0-411c-8742-c6bec7a2c121",
        "bond cleaning": "/web/category-service-form?categoryId=f119a7c0-2048-40b7-92af-a6a5e8c434f2",
        "pest control": "/web/category-service-form?categoryId=a7212a3a-d735-4465-a3c9-e7a32414568a",
        "upholstery": "/web/category-service-form?categoryId=162ba6bd-3f40-492c-8104-5c835dd5a5c9",
        "domestic cleaning": "/web/category-service-form?categoryId=0bff5522-b90d-43b1-b7aa-a473729eaa1b",
        "construction cleaning": "/web/category-service-form?categoryId=3a3c8771-cd02-40e0-8211-fb98a863431b",
        "move in cleaning": "/web/category-service-form?categoryId=16b951bb-9f80-4109-b470-9a9c14dde513",
        "window cleaning": "/web/category-service-form?categoryId=9b931edc-05e4-4647-9736-2deabfef70ec",
        "airbnb cleaning": "/web/category-service-form?categoryId=880e6077-3f33-468b-9b39-bb1646d9cd66",
        "renovation cleaning": "/web/category-service-form?categoryId=a07797ae-a203-47f7-b03f-5d2ab501067a"
    };

    function validateEmail(email) {
        return String(email)
            .toLowerCase()
            .match(
                /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|.(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
            );
    }

    async function processBotResponse(rawInput) {
        const text = rawInput.toLowerCase();
        
        // 0. ONBOARDING FLOW
        if (isWaitingForEmail) {
            if (validateEmail(text)) {
                addMessage("Thank you! Please wait a moment while I set up your account...", 'bot', 500);
                
                try {
                    const response = await fetch('https://app.dirt2tidy.com.au/api/v1/chatbot/onboard', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ email: text })
                    });
                    
                    if (response.ok) {
                        const onboardData = await response.json();
                        isWaitingForEmail = false;
                        currentEmail = text;
                        currentUserId = onboardData.content ? onboardData.content.user_id : null;
                        isNewCustomer = true;

                        addMessage("Success! 🎉 Your account has been created and your login credentials (with a unique 8-digit password) have been sent to your email address.", 'bot', 1000);
                        setTimeout(() => {
                            addMessage("Now, I'm your official AI Assistant. I can help with **Booking any of our 15 services**, **Pricing**, and **Support**. How can I help you today?", 'bot', 600);
                            setTimeout(() => showMainOptions(), 800);
                        }, 1800);
                    } else if (response.status === 400) {
                        const data = await response.json();
                        const errorMsg = data.errors && data.errors[0] ? data.errors[0].message : "This email already has an account. Please share another email.";
                        addMessage(`**${errorMsg}**`, 'bot', 500);
                    } else {
                        addMessage("I'm sorry, I encountered an error. Could you please re-send your email?", 'bot', 500);
                    }
                } catch (error) {
                    addMessage("I'm having trouble connecting to the server. Please try again soon.", 'bot', 500);
                }
            } else {
                addMessage("That doesn't look like a valid email. Please provide a valid email address to continue.", 'bot', 500);
            }
            return;
        }

        // 1. FULL 15 CATEGORY BOOKING FLOW
        if (text.includes('book now') || text.includes('booking')) {
            addMessage("Certainly! We have 15 specialized cleaning services. Please choose one to proceed with your booking:", 'bot', 500);
            setTimeout(() => {
                const row1 = ["End of Lease", "Carpet Steam", "Spring Clean", "Office Clean", "Oven Clean"];
                const row2 = ["BBQ Cleaning", "Bond Cleaning", "Pest Control", "Upholstery", "Domestic Clean"];
                const row3 = ["Construction", "Move In Clean", "Window Clean", "Airbnb Clean", "Renovation"];
                
                addQuickReplies(row1);
                setTimeout(() => {
                    addQuickReplies(row2);
                    setTimeout(() => {
                        addQuickReplies(row3);
                    }, 500);
                }, 500);
            }, 800);
        }

        // 2. CATEGORY REDIRECT LOGIC
        else if (text.includes('lease') || text.includes('carpet') || text.includes('spring') || text.includes('office') || text.includes('oven') || text.includes('bbq') || text.includes('bond') || text.includes('pest') || text.includes('upholstery') || text.includes('domestic') || text.includes('construction') || text.includes('move') || text.includes('window') || text.includes('airbnb') || text.includes('renovation')) {
            let matchedLink = "/web/categories";
            
            if (text.includes('lease')) matchedLink = categoryLinks["end of lease"];
            else if (text.includes('carpet')) matchedLink = categoryLinks["carpet steam"];
            else if (text.includes('spring')) matchedLink = categoryLinks["spring cleaning"];
            else if (text.includes('office')) matchedLink = categoryLinks["office cleaning"];
            else if (text.includes('oven')) matchedLink = categoryLinks["oven cleaning"];
            else if (text.includes('bbq')) matchedLink = categoryLinks["bbq cleaning"];
            else if (text.includes('bond')) matchedLink = categoryLinks["bond cleaning"];
            else if (text.includes('pest')) matchedLink = categoryLinks["pest control"];
            else if (text.includes('upholstery')) matchedLink = categoryLinks["upholstery"];
            else if (text.includes('domestic')) matchedLink = categoryLinks["domestic cleaning"];
            else if (text.includes('construction')) matchedLink = categoryLinks["construction cleaning"];
            else if (text.includes('move')) matchedLink = categoryLinks["move in cleaning"];
            else if (text.includes('window')) matchedLink = categoryLinks["window cleaning"];
            else if (text.includes('airbnb')) matchedLink = categoryLinks["airbnb cleaning"];
            else if (text.includes('renovation')) matchedLink = categoryLinks["renovation cleaning"];

            addMessage(`Great choice! Opening the **${rawInput}** service form now...`, 'bot', 600);
            setTimeout(() => {
                addMessage(`<a href='${matchedLink}' style='font-size:1.1em; font-weight:bold; color:#0461A5;'>🎯 Click here to select your ${rawInput} options</a>`, 'bot', 300);
            }, 1200);
        }

        // 3. PRICING BRANCH
        else if (text.includes('price') || text.includes('pricing') || text.includes('cost')) {
            addMessage("Our rates are very competitive. Which service price do you want to check?", 'bot', 500);
            setTimeout(() => {
                addQuickReplies(["End of Lease Prices", "Carpet/Sofa Prices", "Oven/BBQ Prices", "All Other Rates"]);
            }, 700);
        }

        // 4. SUB-PRICES 
        else if (text.includes('lease prices')) {
            const prices = "🏡 **End of Lease Prices:**<br>🔹 Studio: **$325**<br>🔹 1BR: **$340**<br>🔹 2BR: **$385**<br>🔹 3BR: **$470**";
            addMessage(prices, 'bot', 500);
            setTimeout(() => addQuickReplies(["📅 Book Now", "Main Menu"]), 1000);
        }

        // 5. OTHERS
        else if (text.includes('service') || text.includes('list')) {
            addMessage("We offer 15 premium cleaning services tailored to your needs. From Bond Cleaning to Pest Control, we cover it all!", 'bot', 500);
            setTimeout(() => addQuickReplies(["💰 View Pricing", "📅 Book Now"]), 800);
        }
        else if (text.includes('hi') || text.includes('hello')) {
            addMessage("Hi! How can I help you today?", 'bot', 500);
            setTimeout(() => showMainOptions(), 600);
        }
        else if (text.includes('support')) {
            addMessage("📞 Call: **1300 DIRTY2TIDY**<br>✉️ Email: **support@dirt2tidy.com.au**", 'bot', 500);
        }
        else if (text.includes('menu')) {
            showMainOptions();
        }
        else {
            addMessage("I can definitely help with your cleaning needs. Pick an option below or mention any of our 15 services.", 'bot', 600);
            setTimeout(() => showMainOptions(), 800);
        }
    }
});
