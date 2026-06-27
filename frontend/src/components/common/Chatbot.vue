<template>
  <div>
    <!-- Chat bubble with animation -->
    <div
      v-if="lottieLoaded"
      id="custom-chat-bubble"
      ref="lottieContainer"
      :class="[
        'fixed w-14 h-14 z-[9999] cursor-pointer',
        isDragging
          ? 'cursor-grabbing scale-110 shadow-2xl'
          : (disableHover ? 'cursor-grab transition-all duration-200' : 'cursor-grab hover:scale-105 transition-all duration-200')
      ]"
      :style="chatBubbleStyle"
      @click="openChat"
      @mousedown="startDrag"
      @touchstart.passive="startDrag"
      aria-label="Open chat assistant"
      role="button"
      tabindex="0"
      @keydown.enter="openChat"
      @keydown.space="openChat"
    ></div>
   
    <!-- Chat toggle button -->
    <div
      :class="[
        'fixed z-[9998]',
        isDragging
          ? 'cursor-grabbing scale-110 shadow-2xl'
          : (disableHover ? 'cursor-grab transition-all duration-200' : 'cursor-grab hover:scale-105 transition-all duration-200')
      ]"
      :style="toggleButtonStyle"
      v-if="isVisible"
      @mousedown="startDrag"
      @touchstart.passive="startDrag"
    >
      <button
        @click="toggleChatbot"
        :class="[
          disableHover
            ? 'bg-gradient-to-r from-blue-500 to-blue-600 text-white rounded-full flex items-center justify-center shadow-xl transition-all duration-300'
            : 'bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white rounded-full flex items-center justify-center shadow-xl transition-all duration-300 hover:shadow-2xl hover:scale-105',
          isMobile ? 'w-12 h-12' : 'w-14 h-14'
        ]"
        aria-label="Toggle chat"
      >
        <MessageSquare v-if="!isChatbotOpen" :class="isMobile ? 'w-5 h-5' : 'w-6 h-6'" />
        <X v-else :class="isMobile ? 'w-5 h-5' : 'w-6 h-6'" />
      </button>
     
      <!-- Chat window -->
      <div
        v-if="isChatbotOpen"
        :class="[
          (isMobile && isKeyboardOpen) ? 'fixed bottom-16 right-0' : 'absolute bottom-16 right-0',
          'bg-white rounded-2xl shadow-2xl overflow-hidden transition-all duration-300 flex flex-col border border-gray-100',
          isMobile ? 'w-64' : 'w-80 sm:w-96'
        ]"
        :style="[chatWindowStyle, chatWindowTransformStyle, chatWindowPositionStyle]"
        role="dialog"
        aria-labelledby="chat-title"
      >
        <!-- Chat header -->
        <div :class="[
          'bg-gradient-to-r from-blue-500 to-blue-600 text-white flex items-center gap-3',
          isMobile ? 'p-3' : 'p-4'
        ]" @click="deactivateInput">
          <div :class="[
            'rounded-full bg-white/20 flex items-center justify-center',
            isMobile ? 'w-6 h-6' : 'w-8 h-8'
          ]">
            <img
              src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQGdVf3D-F2UIJ_Lp3GiaZTNcueXQjdy59G2g&s"
              alt="Bot"
              :class="[
                'rounded-full object-cover',
                isMobile ? 'w-4 h-4' : 'w-6 h-6'
              ]"
            />
          </div>
          <div>
            <h3 id="chat-title" :class="[
              'font-semibold',
              isMobile ? 'text-xs' : 'text-sm'
            ]">Provincial Vet Assistant</h3>
            <div class="flex items-center gap-1">
              <div :class="[
                'w-2 h-2 rounded-full',
                isServerOnline ? 'bg-green-400 animate-pulse' : 'bg-red-400'
              ]"></div>
              <p :class="[
                'text-blue-100',
                isMobile ? 'text-xs' : 'text-xs'
              ]">{{ isServerOnline ? 'Online now' : 'Inactive' }}</p>
            </div>
          </div>
        </div>
       
        <!-- Chat messages -->
        <div
          :class="[
            'flex-grow overflow-y-auto bg-gray-50',
            isMobile ? 'p-3' : 'p-4'
          ]"
          ref="chatContainer"
          aria-live="polite"
          @click="deactivateInput"
        >
          <!-- Initial message with suggested queries -->
          <div v-if="messages.length > 0 && messages[0].type === 'bot'" :class="[
            'mb-3',
            isMobile ? 'mb-2' : 'mb-4'
          ]">
              <div class="flex items-start gap-2">
                <div :class="[
                  'rounded-full overflow-hidden flex-shrink-0',
                  isMobile ? 'w-6 h-6' : 'w-8 h-8'
                ]">
                  <img
                    src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQGdVf3D-F2UIJ_Lp3GiaZTNcueXQjdy59G2g&s"
                    alt="Bot"
                    class="w-full h-full object-cover"
                  />
                </div>
              <div class="flex flex-col gap-1">
                <div :class="[
                  'bg-white rounded-2xl rounded-tl-sm max-w-[85%] shadow-sm border border-gray-100',
                  isMobile ? 'p-2' : 'p-3'
                ]">
                  <p :class="[
                    'text-gray-800 leading-relaxed whitespace-pre-wrap',
                    isMobile ? 'text-xs' : 'text-sm'
                  ]" v-html="formatMessage(messages[0].text)"></p>
                </div>
               
                <!-- Suggested Queries directly below initial message -->
                <div v-if="suggestedQueries.length > 0" :class="[
                  'mt-2',
                  isMobile ? 'space-y-1' : 'flex flex-wrap gap-2'
                ]">
                  <div
                    v-for="(query, index) in suggestedQueries"
                    :key="index"
                    :class="[
                      disableHover
                        ? 'bg-white rounded-full relative cursor-pointer border border-gray-200 transition-all duration-200 shadow-sm'
                        : 'bg-white rounded-full relative cursor-pointer hover:bg-blue-50 hover:border-blue-200 border border-gray-200 transition-all duration-200 shadow-sm',
                      isMobile ? 'px-2 py-1.5 pr-6 text-xs block w-full' : 'px-3 py-2 pr-6 text-xs inline-block'
                    ]"
                    @click="sendSuggestedQuery(query)"
                  >
                    {{ query }}
                    <button
                      @click.stop="removeSuggestedQuery(index)"
                      :class="[
                        disableHover ? 'absolute text-gray-400 transition-colors' : 'absolute text-gray-400 hover:text-gray-600 transition-colors',
                        isMobile ? 'right-1 top-1 w-4 h-4 flex items-center justify-center' : 'right-1 top-1.5'
                      ]"
                      aria-label="Remove suggestion"
                    >
                      <X :class="isMobile ? 'w-3 h-3' : 'w-3 h-3'" />
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
         
          <!-- Other messages (after the first one) -->
          <div v-for="(message, index) in messages.slice(1)" :key="index" :class="[
            'mb-3',
            isMobile ? 'mb-2' : 'mb-4'
          ]">
            <div
              v-if="message.type === 'bot'"
              class="flex items-start gap-2"
            >
              <div :class="[
                'rounded-full overflow-hidden flex-shrink-0',
                isMobile ? 'w-6 h-6' : 'w-8 h-8'
              ]">
                <img
                  src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQGdVf3D-F2UIJ_Lp3GiaZTNcueXQjdy59G2g&s"
                  alt="Bot"
                  class="w-full h-full object-cover"
                />
              </div>
              <div :class="[
                'bg-white rounded-2xl rounded-tl-sm max-w-[85%] shadow-sm border border-gray-100',
                isMobile ? 'p-2' : 'p-3'
              ]">
                <p :class="[
                  'text-gray-800 leading-relaxed whitespace-pre-wrap',
                  isMobile ? 'text-xs' : 'text-sm'
                ]" v-html="formatMessage(message.text)"></p>
              </div>
            </div>
            <div
              v-else
              class="flex items-start justify-end gap-2"
            >
              <div :class="[
                'bg-gradient-to-r from-blue-500 to-blue-600 text-white rounded-2xl rounded-tr-sm max-w-[85%] shadow-sm',
                isMobile ? 'p-2' : 'p-3'
              ]">
                <p :class="[
                  'leading-relaxed whitespace-pre-wrap',
                  isMobile ? 'text-xs' : 'text-sm'
                ]">{{ message.text }}</p>
              </div>
              <div :class="[
                'rounded-full overflow-hidden flex-shrink-0',
                isMobile ? 'w-6 h-6' : 'w-8 h-8'
              ]">
                <img
                  :src="userProfilePicture"
                  alt="User"
                  class="w-full h-full object-cover"
                />
              </div>
            </div>
          </div>
         
          <!-- Typing indicator -->
          <div v-if="isTyping" class="flex items-start gap-2">
            <div :class="[
              'rounded-full overflow-hidden flex-shrink-0',
              isMobile ? 'w-6 h-6' : 'w-8 h-8'
            ]">
              <img
                src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQGdVf3D-F2UIJ_Lp3GiaZTNcueXQjdy59G2g&s"
                alt="Bot"
                class="w-full h-full object-cover"
              />
            </div>
            <div :class="[
              'bg-white rounded-2xl rounded-tl-sm shadow-sm border border-gray-100',
              isMobile ? 'p-2' : 'p-3'
            ]">
              <div class="flex space-x-1" aria-label="Bot is typing">
                <div :class="[
                  'bg-blue-400 rounded-full animate-bounce',
                  isMobile ? 'w-1.5 h-1.5' : 'w-2 h-2'
                ]"></div>
                <div :class="[
                  'bg-blue-400 rounded-full animate-bounce',
                  isMobile ? 'w-1.5 h-1.5' : 'w-2 h-2'
                ]" style="animation-delay: 0.2s"></div>
                <div :class="[
                  'bg-blue-400 rounded-full animate-bounce',
                  isMobile ? 'w-1.5 h-1.5' : 'w-2 h-2'
                ]" style="animation-delay: 0.4s"></div>
              </div>
            </div>
          </div>
        </div>
       
        <!-- Chat input -->
        <div :class="[
          'bg-white border-t border-gray-100',
          isMobile ? 'p-1.5' : 'p-4'
        ]" @click="activateInput">
          <form @submit.prevent="sendMessage" :class="[
            'flex',
            isMobile ? 'gap-1' : 'gap-2'
          ]">
            <label for="chat-input" class="sr-only">Type your message</label>
            <textarea
              id="chat-input"
              v-model="userInput"
              placeholder="Type your message..."
              :class="[
                'flex-grow border border-gray-200 rounded-full focus:outline-none focus:ring-0 focus:border-blue-300 bg-gray-50 resize-none overflow-y-auto',
                isMobile ? 'px-1.5 py-0.5 text-xs' : 'px-3 py-2 text-sm'
              ]"
              :style="isMobile ? 'height: 32px; max-height: 32px;' : 'height: 40px; max-height: 40px;'"
              :disabled="isTyping"
              @click.stop
              @focus="onInputFocus"
              @blur="handleInputBlur"
              @keydown="handleKeydown"
              ref="chatInput"
              rows="1"
            ></textarea>
            <button
              type="submit"
              :class="[
                disableHover
                  ? 'bg-gradient-to-r from-blue-500 to-blue-600 text-white rounded-full focus:outline-none focus:ring-2 focus:ring-blue-300 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 shadow-sm flex items-center justify-center'
                  : 'bg-gradient-to-r from-blue-500 to-blue-600 text-white rounded-full hover:from-blue-600 hover:to-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-300 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 shadow-sm flex items-center justify-center',
                isMobile ? 'w-5 h-5' : 'w-10 h-10'
              ]"
              :disabled="isTyping || !userInput.trim()"
              aria-label="Send message"
            >
              <Send :class="isMobile ? 'w-2.5 h-2.5' : 'w-5 h-5'" />
            </button>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>


<script>
import axios from "axios";
import { nanoid } from "nanoid";
import { MessageSquare, X, Send } from 'lucide-vue-next';
import { useProfileStore } from '@/stores/modules/profileStore';
import { useAuthStore } from '@/stores/modules/authStore';
import { storeToRefs } from 'pinia';


export default {
  name: "Chatbot",
  components: {
    MessageSquare,
    X,
    Send
  },
  props: {
    initialMessage: {
      type: String,
      default: "Hello! I'm ProBot, your virtual assistant. How can I help you today? Please use the navigation below or ask me anything."
    },
    apiBaseUrl: {
      type: String,
      default: "http://localhost:3001"
    }
  },
  data() {
    return {
      userInput: "",
      messages: [],
      isTyping: false,
      isChatbotOpen: false,
      isVisible: true,
      lottieLoaded: false,
      sessionId: "",
      lottiePlayer: null,
      apiUrl: "",
      retryCount: 0,
      maxRetries: 2,  // Reduced from 3 to 2 for faster fallback
      requestTimeoutMs: 35000,  // 35 seconds timeout
      suggestedQueries: [
        "How do I schedule an appointment?",
        "What services do you offer?",
        "What are your operating hours?",
        "Where is your office?"
      ],
      // Dragging functionality
      isDragging: false,
      dragStart: { x: 0, y: 0 },
      position: { x: 20, y: 100 }, // Default position (right: 20px, bottom: 100px)
      dragStartTime: 0,
      dragThreshold: 15, // Higher threshold for desktop to prevent accidental drags
      isMobile: false,
      mobileDragThreshold: 10, // Higher threshold for mobile to make dragging easier
      dragStartDelay: 100, // Minimum delay before drag can start on desktop
      focusInterval: null, // For maintaining focus
      // Input focus control
      autoFocusEnabled: false,
      // Backend connection status
      isServerOnline: true,
      // Keyboard/viewport handling
      keyboardExtraBottom: 0,
      isKeyboardOpen: false
    }
  },
  computed: {
    chatEndpoint() {
      return `${this.apiBaseUrl}/chat`;
    },
    healthEndpoint() {
      return `${this.apiBaseUrl}/health`;
    },
    userProfilePicture() {
      const profileStore = useProfileStore();
      const authStore = useAuthStore();
     
      // Try to get profile picture from profile store first
      if (profileStore.profile && profileStore.profile.photoURL) {
        return profileStore.profile.photoURL;
      }
     
      // Fall back to auth store if available
      if (authStore.user && authStore.user.photoURL) {
        return authStore.user.photoURL;
      }
     
      // Default placeholder if no profile picture is available
      return 'https://ui-avatars.com/api/?name=User&background=0D8ABC&color=fff';
    },
    chatBubbleStyle() {
      // Use the same positioning logic for both mobile and desktop
      return {
        right: `${this.position.x}px`,
        bottom: `calc(${this.position.y + (this.isMobile && this.isChatbotOpen ? this.keyboardExtraBottom : 0)}px + env(safe-area-inset-bottom))`
      };
    },
    toggleButtonStyle() {
      // Use the same positioning logic for both mobile and desktop
      return {
        right: `${this.position.x + 4}px`,
        bottom: `calc(${this.position.y + 56 + (this.isMobile && this.isChatbotOpen ? this.keyboardExtraBottom : 0)}px + env(safe-area-inset-bottom))`
      };
    },
    disableHover() {
      return this.isMobile && this.isChatbotOpen;
    },
    chatWindowStyle() {
      if (!this.isMobile) {
        return 'height: 500px; max-height: calc(100vh - 120px); padding-bottom: env(safe-area-inset-bottom);';
      }
      const vv = window.visualViewport;
      const available = vv ? vv.height : window.innerHeight;
      // Reserve space for header/toggle etc.
      const baseGap = this.isKeyboardOpen ? 120 : 90;
      const maxHeight = Math.max(250, available - baseGap);
      const desired = 350;
      const height = Math.min(desired, maxHeight);
      return `height: ${height}px; max-height: ${maxHeight}px; padding-bottom: env(safe-area-inset-bottom);`;
    },
    chatWindowTransformStyle() {
      const isFixed = this.isMobile && this.isChatbotOpen && this.isKeyboardOpen;
      if (isFixed) {
        // When using fixed + explicit bottom, avoid extra transform to prevent overshoot
        return '';
      }
      return '';
    },
    chatWindowPositionStyle() {
      if (this.isMobile && this.isChatbotOpen && this.isKeyboardOpen) {
        // Override Tailwind bottom-16 with inline style that adds keyboard offset
        return { bottom: `calc(4rem + ${this.keyboardExtraBottom}px + env(safe-area-inset-bottom))` };
      }
      return {};
    }
  },
  created() {
    // Generate a unique session ID for this chat
    this.sessionId = nanoid();
   
    // Set API URL from props
    this.apiUrl = this.chatEndpoint;
  },
  mounted() {
    // Detect mobile device
    this.isMobile = window.innerWidth < 768 || /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
   
    // Set appropriate default position based on device type
    if (this.isMobile) {
      // Default mobile position - ensure it's visible and accessible
      this.position = { x: 20, y: 20 };
    } else {
      // Load saved position for desktop
      this.loadPosition();
    }
   
    // Add welcome message
    this.addBotMessage(this.initialMessage);
   
    // Test connection to server
    this.testServerConnection();
   
    // Initialize Lottie animation
    this.loadLottiePlayer().then(() => {
      this.initializeLottie();
    }).catch(error => {
      console.error("Failed to load Lottie player:", error);
      // Still show the chat button even if Lottie fails
      this.lottieLoaded = true;
    });


    // Add event listener for keyboard accessibility
    document.addEventListener('keydown', this.handleKeyDown);
   
    // Add window resize listener to adjust position if needed
    window.addEventListener('resize', this.handleResize);


    // VisualViewport to detect on-screen keyboard on mobile
    if (window.visualViewport) {
      window.visualViewport.addEventListener('resize', this.updateViewport, { passive: true });
      window.visualViewport.addEventListener('scroll', this.updateViewport, { passive: true });
      this.updateViewport();
    }
   
    // Add click listener to close chatbot when clicking navigation elements
    document.addEventListener('click', this.handleNavigationClick);
   
    // Listen for route changes to close chatbot
    this.$router.afterEach(() => {
      if (this.isChatbotOpen) {
        this.isChatbotOpen = false;
        this.stopFocusMaintenance();
      }
    });
  },
  beforeUnmount() {
    // Clean up event listeners
    document.removeEventListener('keydown', this.handleKeyDown);
    window.removeEventListener('resize', this.handleResize);
    if (window.visualViewport) {
      window.visualViewport.removeEventListener('resize', this.updateViewport);
      window.visualViewport.removeEventListener('scroll', this.updateViewport);
    }
    document.removeEventListener('click', this.handleNavigationClick);
   
    // Clean up drag event listeners if still dragging
    if (this.isDragging) {
      document.removeEventListener('mousemove', this.onDrag);
      document.removeEventListener('mouseup', this.endDrag);
      document.removeEventListener('touchmove', this.onDrag);
      document.removeEventListener('touchend', this.endDrag);
    }
   
    // Clean up focus maintenance
    this.stopFocusMaintenance();
   
    // Clean up Lottie player if needed
    if (this.lottiePlayer) {
      this.lottiePlayer = null;
    }
  },
  methods: {
    handleResize() {
      // Re-evaluate mobile breakpoint and clamp within viewport
      this.isMobile = window.innerWidth < 768 || /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
      this.updateViewport();
    },
    updateViewport() {
      if (!this.isMobile) {
        this.keyboardExtraBottom = 0;
        this.isKeyboardOpen = false;
        return;
      }
      const vv = window.visualViewport;
      if (vv) {
        const keyboardEstimate = Math.max(0, window.innerHeight - vv.height - vv.offsetTop);
        // If significant height reduction, consider keyboard open
        this.isKeyboardOpen = keyboardEstimate > 60;
        // Push UI just above keyboard with a gap
        const extraGap = 48;
        this.keyboardExtraBottom = this.isChatbotOpen && this.isKeyboardOpen ? Math.max(0, keyboardEstimate + extraGap) : 0;
      }
    },
    ensureInputVisible() {
      this.$nextTick(() => {
        const inputField = this.$refs.chatInput;
        const vv = window.visualViewport;
        if (!inputField) return;
        // Try using bounding rect to compute overlap
        const rect = inputField.getBoundingClientRect();
        const viewportH = vv ? vv.height : window.innerHeight;
        const overlap = rect.bottom + 8 - viewportH;
        if (overlap > 0) {
          this.isKeyboardOpen = true;
          this.keyboardExtraBottom = Math.max(this.keyboardExtraBottom, overlap + 28);
        }
        // Run again shortly after to catch keyboard animation
        setTimeout(() => {
          const rect2 = inputField.getBoundingClientRect();
          const viewportH2 = vv ? vv.height : window.innerHeight;
          const overlap2 = rect2.bottom + 8 - viewportH2;
          if (overlap2 > 0) {
            this.isKeyboardOpen = true;
            this.keyboardExtraBottom = Math.max(this.keyboardExtraBottom, overlap2 + 48);
          }
          // Proactively scroll the input into view for iOS Safari
          try {
            inputField.scrollIntoView({ block: 'end', inline: 'nearest', behavior: 'smooth' });
          } catch (_) {}
          this.scrollToBottom();
        }, 220);


        // One more pass after keyboard fully settles
        setTimeout(() => {
          const rect3 = inputField.getBoundingClientRect();
          const viewportH3 = vv ? vv.height : window.innerHeight;
          const overlap3 = rect3.bottom + 8 - viewportH3;
          if (overlap3 > 0) {
            this.isKeyboardOpen = true;
            this.keyboardExtraBottom = Math.max(this.keyboardExtraBottom, overlap3 + 48);
            try {
              inputField.scrollIntoView({ block: 'end', inline: 'nearest', behavior: 'smooth' });
            } catch (_) {}
            this.scrollToBottom();
          }
        }, 420);
      });
    },
    async testServerConnection() {
      try {
        // Test if the server is reachable
        await axios.get(this.healthEndpoint);
        console.log("Server connection successful");
        this.isServerOnline = true;
      } catch (error) {
        console.error("Server connection failed:", error);
        this.isServerOnline = false;
        this.addBotMessage("Warning: I'm having trouble connecting to the server. Some features may not work properly.");
      }
    },
    async loadLottiePlayer() {
      return new Promise((resolve, reject) => {
        // Check if already loaded
        if (document.querySelector('script[src*="dotlottie-player"]')) {
          resolve();
          return;
        }
       
        const script = document.createElement('script');
        script.src = "https://unpkg.com/@dotlottie/player-component@2.7.12/dist/dotlottie-player.mjs";
        script.type = "module";
        script.onload = () => {
          console.log("Lottie player script loaded");
          resolve();
        };
        script.onerror = (error) => {
          console.error("Failed to load Lottie player script:", error);
          reject(error);
        };
        document.head.appendChild(script);
      });
    },
    initializeLottie() {
      if (!this.$refs.lottieContainer) return;
     
      try {
        // Create the player element programmatically
        const player = document.createElement('dotlottie-player');
        player.setAttribute('src', 'https://lottie.host/b202c548-8602-4982-a7dc-8f7db1df371f/SOWn3JnOYp.lottie');
        player.setAttribute('background', 'transparent');
        player.setAttribute('speed', '1');
        player.setAttribute('loop', '');
        player.setAttribute('autoplay', '');
        player.style.width = '100%';
        player.style.height = '100%';
       
        // Append to the container
        this.$refs.lottieContainer.appendChild(player);
        this.lottiePlayer = player;
        this.lottieLoaded = true;
      } catch (error) {
        console.error("Error initializing Lottie:", error);
        this.lottieLoaded = true; // Still show the chat button
      }
    },
    openChat(event) {
      // Prevent click if we were just dragging
      const timeSinceStart = Date.now() - this.dragStartTime;
      if (this.isDragging || (this.dragStartTime && timeSinceStart > 300)) {
        event.preventDefault();
        return;
      }
     
      this.isChatbotOpen = true;
      this.$nextTick(() => {
        this.scrollToBottom();
        // Auto-focus on first open so keyboard is active immediately
        this.autoFocusEnabled = true;
        this.startFocusMaintenance();
        this.focusInput();
        this.ensureInputVisible();
        this.updateViewport();
      });
    },
    toggleChatbot(event) {
      // Prevent click if we were just dragging
      const timeSinceStart = Date.now() - this.dragStartTime;
      if (this.isDragging || (this.dragStartTime && timeSinceStart > 300)) {
        event.preventDefault();
        return;
      }
     
      this.isChatbotOpen = !this.isChatbotOpen;
      if (this.isChatbotOpen) {
        this.$nextTick(() => {
          this.scrollToBottom();
          // Auto-focus when opening so keyboard shows immediately
          this.autoFocusEnabled = true;
          this.startFocusMaintenance();
          this.focusInput();
          this.ensureInputVisible();
          this.updateViewport();
        });
      } else {
        // Stop focus maintenance when chat closes
        this.stopFocusMaintenance();
        this.keyboardExtraBottom = 0;
        this.isKeyboardOpen = false;
      }
    },
    handleKeyDown(event) {
      // Close chat on Escape key
      if (event.key === 'Escape' && this.isChatbotOpen) {
        this.toggleChatbot();
      }
    },
    // New method to handle suggested query clicks
    sendSuggestedQuery(query) {
      this.userInput = query;
      this.sendMessage();
    },
    // New method to remove a suggested query
    removeSuggestedQuery(index) {
      this.suggestedQueries.splice(index, 1);
    },
    async sendMessage() {
      if (!this.userInput.trim() || this.isTyping) return;


      // Add user message to chat
      this.addUserMessage(this.userInput);
      const userMessage = this.userInput;
      this.userInput = "";


      // Keep input focused after sending message
      this.focusInput();


      // Show typing indicator
      this.isTyping = true;


      try {
        console.log("Sending message to:", this.apiUrl);
       
        // Create a timeout promise to handle request timeouts
        const timeoutPromise = new Promise((_, reject) => {
          setTimeout(() => reject(new Error("Request timed out")), this.requestTimeoutMs);
        });
       
        // Send message to backend with a race against the timeout
        const response = await Promise.race([
          axios.post(this.apiUrl, {
            message: userMessage,
            sender_id: this.sessionId,
          }, {
            timeout: this.requestTimeoutMs // Use the timeout from data
          }),
          timeoutPromise
        ]);


        // Process response
        if (response.data && response.data.messages && response.data.messages.length > 0) {
          this.isServerOnline = true;
          // Add a small delay to simulate typing
          setTimeout(() => {
            response.data.messages.forEach((msg) => {
              this.addBotMessage(msg.text);
            });
            this.isTyping = false;
            this.retryCount = 0; // Reset retry count on success
           
            // Keep input focused after bot responds
            this.focusInput();
          }, 500);
        } else {
          this.handleError("Received empty response from server");
        }
      } catch (error) {
        console.error("Error sending message:", error);
        this.isServerOnline = false;
       
        // Implement retry logic
        if (this.retryCount < this.maxRetries) {
          this.retryCount++;
          console.log(`Retrying (${this.retryCount}/${this.maxRetries})...`);
         
          setTimeout(() => {
            this.retryMessage(userMessage);
          }, 1000 * this.retryCount); // Exponential backoff
        } else {
          // Use direct fallback after all retries fail
          this.directFallback(userMessage);
          // Keep input focused after fallback
          this.focusInput();
        }
      }
    },
   
    async retryMessage(userMessage) {
      try {
        const response = await axios.post(this.apiUrl, {
          message: userMessage,
          sender_id: this.sessionId,
        }, {
          timeout: this.requestTimeoutMs
        });


        if (response.data && response.data.messages && response.data.messages.length > 0) {
          this.isServerOnline = true;
          setTimeout(() => {
            response.data.messages.forEach((msg) => {
              this.addBotMessage(msg.text);
            });
            this.isTyping = false;
            this.retryCount = 0; // Reset retry count on success
           
            // Keep input focused after retry success
            this.focusInput();
          }, 500);
        } else {
          this.directFallback(userMessage);
        }
      } catch (error) {
        this.isServerOnline = false;
        this.directFallback(userMessage);
      }
    },
   
    async directFallback(userMessage) {
      // This is a client-side fallback when the server times out
      const fallbackMessages = [
        "I'm sorry, I couldn't get a response from the server in time. Please try again later.",
        "It seems our server is taking too long to respond. Your question might be complex or our system might be busy.",
        "I apologize for the delay. Our server is taking longer than expected to process your request."
      ];
     
      // Pick a random fallback message
      const randomIndex = Math.floor(Math.random() * fallbackMessages.length);
      this.addBotMessage(fallbackMessages[randomIndex]);
      this.isTyping = false;
     
      // Keep input focused after fallback
      this.focusInput();
    },
   
    addUserMessage(text) {
      this.messages.push({
        text,
        type: "user",
      });
      this.scrollToBottom();
    },
   
    addBotMessage(text) {
      this.messages.push({
        text,
        type: "bot",
      });
      this.scrollToBottom();
    },
   
    handleError(errorMessage) {
      this.isTyping = false;
      this.addBotMessage(`I'm sorry, I'm having trouble connecting right now. ${errorMessage ? `Error: ${errorMessage}` : 'Please try again later.'}`);
    },
   
    scrollToBottom() {
      this.$nextTick(() => {
        if (this.$refs.chatContainer) {
          this.$refs.chatContainer.scrollTop = this.$refs.chatContainer.scrollHeight;
        }
      });
    },
   
    formatMessage(text) {
      if (!text) return '';
     
      // Convert URLs to clickable links with proper security attributes
      return text.replace(
        /(https?:\/\/[^\s]+)/g,
        '<a href="$1" target="_blank" rel="noopener noreferrer" class="text-blue-600 hover:underline">$1</a>'
      );
    },
   
    // Method to ensure input stays focused (only if autoFocusEnabled)
    focusInput() {
      this.$nextTick(() => {
        const inputField = document.getElementById('chat-input');
        if (inputField && this.autoFocusEnabled) {
          inputField.focus();
          // Force focus with a small delay to ensure it works
          setTimeout(() => {
            if (inputField && this.autoFocusEnabled) {
              inputField.focus();
            }
          }, 10);
        }
      });
    },
   
    // Handle input blur - prevent losing focus unless user clicks outside chat
    handleInputBlur(event) {
      // Only refocus if the blur is not caused by clicking outside the chat window
      const chatWindow = event.target.closest('.absolute');
      if (chatWindow && this.isChatbotOpen && this.autoFocusEnabled) {
        // Small delay to allow other focus events to complete
        setTimeout(() => {
          this.focusInput();
        }, 50);
      }
      // If blur due to closing keyboard, refresh viewport
      this.updateViewport();
    },
   
    // Handle keydown events for textarea
    handleKeydown(event) {
      if (event.key === 'Enter') {
        if (event.shiftKey) {
          // Shift+Enter: Allow new line (default behavior)
          return;
        } else {
          // Enter: Send message
          event.preventDefault();
          this.sendMessage();
        }
      }
    },
   
    // Start focus maintenance when chat opens
    startFocusMaintenance() {
      if (this.focusInterval) {
        clearInterval(this.focusInterval);
      }
      this.focusInterval = setInterval(() => {
        if (this.isChatbotOpen && !this.isTyping && this.autoFocusEnabled) {
          const inputField = document.getElementById('chat-input');
          if (inputField && document.activeElement !== inputField) {
            inputField.focus();
          }
        }
      }, 1000); // Check every second
    },
   
    // Stop focus maintenance when chat closes
    stopFocusMaintenance() {
      if (this.focusInterval) {
        clearInterval(this.focusInterval);
        this.focusInterval = null;
      }
    },
   
    // Handle navigation clicks to close chatbot
    handleNavigationClick(event) {
      if (!this.isChatbotOpen) return;
     
      // Check if the clicked element is a navigation element
      const target = event.target;
      const isNavigationElement = target.closest('a[href]') ||
                                 target.closest('button[data-navigation]') ||
                                 target.closest('.router-link') ||
                                 target.closest('[role="menuitem"]') ||
                                 target.closest('.nav-item') ||
                                 target.closest('.navigation-item') ||
                                 target.closest('nav a') ||
                                 target.closest('.sidebar a') ||
                                 target.closest('.menu-item') ||
                                 target.closest('[data-route]');
     
      // Check if it's a chatbot element (don't close if clicking on chatbot)
      const isChatbotElement = target.closest('.absolute.bottom-16') ||
                              target.closest('button[aria-label="Toggle chat"]') ||
                              target.closest('#custom-chat-bubble') ||
                              target.closest('button[aria-label="Send message"]') ||
                              target.closest('#chat-input');
     
      // Close chatbot if clicking on navigation elements but not on chatbot itself
      if (isNavigationElement && !isChatbotElement) {
        this.isChatbotOpen = false;
        this.stopFocusMaintenance();
      }
    },


    // Tap-to-focus / Tap-away-to-dismiss
    onInputFocus() {
      this.autoFocusEnabled = true;
      this.ensureInputVisible();
      this.startFocusMaintenance();
    },
    activateInput() {
      this.autoFocusEnabled = true;
      this.$nextTick(() => {
        const inputField = this.$refs.chatInput || document.getElementById('chat-input');
        if (inputField) {
          try { inputField.focus(); } catch (_) {}
        }
        this.ensureInputVisible();
        this.startFocusMaintenance();
      });
    },
    deactivateInput() {
      this.autoFocusEnabled = false;
      const inputField = this.$refs.chatInput;
      if (inputField) {
        inputField.blur();
      }
      this.stopFocusMaintenance();
    },
   
    // Drag functionality methods
    startDrag(event) {
      // Don't prevent default on touch events to allow proper touch handling
      if (event.type === 'mousedown') {
        event.preventDefault();
      }
      event.stopPropagation();
     
      this.isDragging = false;
      this.dragStartTime = Date.now();
     
      // Get initial mouse/touch position
      const clientX = event.type === 'mousedown' ? event.clientX : event.touches[0].clientX;
      const clientY = event.type === 'mousedown' ? event.clientY : event.touches[0].clientY;
     
      // Store the initial click position
      this.dragStart = { x: clientX, y: clientY };
     
      // Add event listeners for drag
      document.addEventListener('mousemove', this.onDrag);
      document.addEventListener('mouseup', this.endDrag);
      document.addEventListener('touchmove', this.onDrag, { passive: false });
      document.addEventListener('touchend', this.endDrag);
     
      // Prevent text selection during drag
      document.body.style.userSelect = 'none';
     
      // Prevent scrolling on mobile during drag
      if (this.isMobile) {
        document.body.style.overflow = 'hidden';
      }
    },
   
    onDrag(event) {
      event.preventDefault();
     
      const clientX = event.type === 'mousemove' ? event.clientX : event.touches[0].clientX;
      const clientY = event.type === 'mousemove' ? event.clientY : event.touches[0].clientY;
     
      // Calculate distance moved from initial start position
      const deltaX = Math.abs(clientX - this.dragStart.x);
      const deltaY = Math.abs(clientY - this.dragStart.y);
      const distance = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
     
      // Start dragging if moved beyond threshold (use mobile-specific threshold)
      const threshold = this.isMobile ? this.mobileDragThreshold : this.dragThreshold;
      const timeSinceStart = Date.now() - this.dragStartTime;
     
      // On desktop, require both distance AND time delay to prevent accidental drags
      if (!this.isDragging && distance > threshold) {
        if (this.isMobile || timeSinceStart > this.dragStartDelay) {
          this.isDragging = true;
          // Add visual feedback when dragging starts
          if (this.$refs.lottieContainer) {
            this.$refs.lottieContainer.style.transform = 'scale(1.1)';
          }
        }
      }
     
      if (this.isDragging) {
        // Position the chatbot center exactly where the cursor is
        // Convert cursor position to bottom-right positioning with center alignment
        const minDistanceFromTop = this.isMobile ? 60 : 80; // Prevent going too high
        const minDistanceFromBottom = 20; // Keep some space from bottom
        const minDistanceFromSides = 20; // Keep some space from sides
       
        const newX = Math.max(minDistanceFromSides, Math.min(window.innerWidth - 56 - minDistanceFromSides, window.innerWidth - clientX - 28));
        const newY = Math.max(minDistanceFromTop, Math.min(window.innerHeight - 56 - minDistanceFromBottom, window.innerHeight - clientY - 28));
       
        this.position = { x: newX, y: newY };
       
        // Debug log (remove this later)
        console.log('Dragging to:', this.position, 'Cursor:', clientX, clientY);
      }
    },
   
    endDrag(event) {
      const wasDragging = this.isDragging;
      const dragDuration = Date.now() - this.dragStartTime;
     
      this.isDragging = false;
     
      // Remove event listeners
      document.removeEventListener('mousemove', this.onDrag);
      document.removeEventListener('mouseup', this.endDrag);
      document.removeEventListener('touchmove', this.onDrag);
      document.removeEventListener('touchend', this.endDrag);
     
      // Restore text selection
      document.body.style.userSelect = '';
     
      // Restore scrolling on mobile
      if (this.isMobile) {
        document.body.style.overflow = '';
      }
     
      // Reset visual feedback
      if (this.$refs.lottieContainer) {
        this.$refs.lottieContainer.style.transform = '';
      }
     
      // Save position to localStorage if we were dragging
      if (wasDragging) {
        this.savePosition();
      }
     
      // Reset drag start time after a short delay to allow click events
      setTimeout(() => {
        this.dragStartTime = 0;
        // Also reset dragging state if it wasn't actually dragging
        if (!wasDragging) {
          this.isDragging = false;
        }
      }, 100);
    },
   
    savePosition() {
      try {
        // Save position with device type to handle mobile vs desktop differently
        const positionData = {
          position: this.position,
          isMobile: this.isMobile,
          timestamp: Date.now()
        };
        localStorage.setItem('chatbot-position', JSON.stringify(positionData));
      } catch (error) {
        console.warn('Could not save chatbot position:', error);
      }
    },
   
    loadPosition() {
      try {
        const savedData = localStorage.getItem('chatbot-position');
        if (savedData) {
          const data = JSON.parse(savedData);
         
          // If the saved data is from the same device type, use it
          if (data.isMobile === this.isMobile && data.position) {
            const position = data.position;
            const minDistanceFromTop = this.isMobile ? 60 : 80;
            const minDistanceFromBottom = 20;
            const minDistanceFromSides = 20;
           
            // Validate position is within bounds with constraints
            if (position.x >= minDistanceFromSides && position.x <= window.innerWidth - 56 - minDistanceFromSides &&
                position.y >= minDistanceFromTop && position.y <= window.innerHeight - 56 - minDistanceFromBottom) {
              this.position = position;
            }
          }
        }
      } catch (error) {
        console.warn('Could not load chatbot position:', error);
      }
    },
   
    handleResize() {
      // Update mobile detection
      const wasMobile = this.isMobile;
      this.isMobile = window.innerWidth < 768 || /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
     
      // If switching from mobile to desktop, load saved position
      if (wasMobile && !this.isMobile) {
        this.loadPosition();
      }
      // If switching from desktop to mobile, set default mobile position
      else if (!wasMobile && this.isMobile) {
        this.position = { x: 20, y: 20 };
      }
     
      // Adjust position if window is resized and chatbot is outside bounds
      const minDistanceFromTop = this.isMobile ? 60 : 80;
      const minDistanceFromBottom = 20;
      const minDistanceFromSides = 20;
     
      const maxX = window.innerWidth - 56 - minDistanceFromSides;
      const maxY = window.innerHeight - 56 - minDistanceFromBottom;
     
      if (this.position.x > maxX) {
        this.position.x = maxX;
      }
      if (this.position.x < minDistanceFromSides) {
        this.position.x = minDistanceFromSides;
      }
      if (this.position.y > maxY) {
        this.position.y = maxY;
      }
      if (this.position.y < minDistanceFromTop) {
        this.position.y = minDistanceFromTop;
      }
     
      // Save the adjusted position (works for both mobile and desktop)
      this.savePosition();
    }
  }
}
</script>


<style scoped>
.animate-bounce {
  animation: bounce 1s infinite;
}


@keyframes bounce {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-4px);
  }
}


/* Improve focus styles for accessibility */
button:focus,
input:focus,
[role="button"]:focus {
  outline: 2px solid #3b82f6;
  outline-offset: 2px;
}


/* Ensure text has sufficient contrast */
.text-gray-800 {
  color: #1f2937;
}


/* Desktop-specific styles */
@media (min-width: 768px) {
  #custom-chat-bubble {
    /* Ensure proper mouse interaction on desktop */
    pointer-events: auto !important;
    touch-action: auto !important; /* Allow normal mouse interaction */
    -webkit-user-select: none;
    user-select: none;
    cursor: grab;
  }
 
  #custom-chat-bubble:hover {
    cursor: grab;
    transform: scale(1.05);
    transition: transform 0.2s ease;
  }
 
  #custom-chat-bubble:active {
    cursor: grabbing;
  }
 
  .fixed.z-\[9998\] {
    pointer-events: auto !important;
    touch-action: auto !important; /* Allow normal mouse interaction */
    -webkit-user-select: none;
    user-select: none;
  }
}


/* Mobile-specific styles */
@media (max-width: 767px) {
  #custom-chat-bubble {
    /* Ensure the chatbot is always clickable and draggable on mobile */
    pointer-events: auto !important;
    touch-action: none !important; /* Allow dragging */
    -webkit-tap-highlight-color: rgba(0, 0, 0, 0.1);
    -webkit-user-select: none;
    user-select: none;
  }
 
  /* Make sure the chatbot button is always visible and clickable */
  .fixed.z-\[9998\] {
    pointer-events: auto !important;
    touch-action: none !important; /* Allow dragging */
    -webkit-user-select: none;
    user-select: none;
  }
 
  /* Ensure proper touch targets */
  #custom-chat-bubble,
  .fixed.z-\[9998\] button {
    min-width: 44px;
    min-height: 44px;
  }
 
  /* Improve dragging experience on mobile */
  #custom-chat-bubble:active,
  .fixed.z-\[9998\]:active {
    transform: scale(1.05);
    transition: transform 0.1s ease;
  }
}
</style>

















