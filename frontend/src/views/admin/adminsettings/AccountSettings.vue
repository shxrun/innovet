<!-- views/adminsettings/AccountSettings.vue -->
<template>
  <div class="p-3 sm:p-4 md:p-6 bg-white rounded-2xl">
    <div class="mb-4 sm:mb-6 md:mb-8">
      <h1 class="text-xl sm:text-2xl font-semibold text-gray-900">Account Settings</h1>
      <p class="text-sm sm:text-base text-gray-500 mt-1">Manage your account preferences.</p>
    </div>
    
    <!-- Navigation Tabs -->
    <div class="mb-4 sm:mb-6">
      <nav class="flex space-x-2 sm:space-x-4 md:space-x-8 mb-3 sm:mb-4 overflow-x-auto">
        <button
          v-for="tab in tabs" 
          :key="tab.id"
          @click="currentTab = tab.id"
          :class="[
            'whitespace-nowrap py-1.5 sm:py-2 px-2 sm:px-3 md:px-4 text-xs sm:text-sm font-medium rounded-full transition-colors',
            currentTab === tab.id 
              ? 'bg-[#EBF5FF] text-[#0066FF]'
              : 'text-gray-800 hover:text-gray-700'
          ]"
        >
          <div class="flex items-center space-x-1 sm:space-x-2">
            <component :is="tab.icon" class="w-4 h-4 sm:w-5 sm:h-5" />
            <span>{{ tab.name }}</span>
          </div>
        </button>
      </nav>
      <div class="border-b border-gray-200"></div>
    </div>

    <!-- Main Content -->
    <div>
      <!-- Account Tab Content -->
      <div v-if="currentTab === 'account'" class="flex flex-col gap-4 sm:gap-6 md:gap-8">
        <div class="flex flex-col lg:flex-row gap-4 sm:gap-6 md:gap-8">
          <!-- Change Profile Container -->
          <div class="flex-1 bg-white rounded-xl border border-gray-200 overflow-hidden">
            <div class="p-3 sm:p-4 md:p-6">
              <div class="flex items-center gap-2 sm:gap-3 mb-4 sm:mb-6">
                <UserIcon class="w-4 h-4 sm:w-5 sm:h-5 text-gray-500" />
                <div>
                  <h2 class="text-lg sm:text-xl font-semibold text-gray-900">Change Profile</h2>
                  <p class="text-xs sm:text-sm text-gray-500">Change your profile picture from here</p>
                </div>
              </div>
              
              <div class="flex flex-col items-center">
                <div class="relative">
                  <img
                    :src="profileImage || currentProfilePicture"
                    alt="Profile"
                    class="w-20 h-20 sm:w-24 sm:h-24 md:w-32 md:h-32 rounded-full bg-gray-100 object-cover"
                  />
                </div>
                
                <div class="mt-4 sm:mt-6 md:mt-8 flex flex-row gap-2 sm:gap-4">
                  <button
                    v-if="!photoChanged"
                    @click="fileInput.click()"
                    class="flex-1 px-3 sm:px-4 md:px-5 py-1.5 sm:py-2 md:py-2.5 bg-blue-500 text-white rounded-full hover:bg-blue-600 transition-colors flex items-center justify-center space-x-1 sm:space-x-2 text-xs sm:text-sm min-h-[40px] sm:min-h-[44px]"
                  >
                    <UploadIcon class="w-3 h-3 sm:w-4 sm:h-4" />
                    <span>Upload</span>
                  </button>
                  <button
                    v-if="photoChanged"
                    @click="saveProfilePicture"
                    :disabled="isUploadingProfilePicture"
                    class="flex-1 px-3 sm:px-4 md:px-5 py-1.5 sm:py-2 md:py-2.5 bg-green-500 text-white rounded-full hover:bg-green-600 transition-colors flex items-center justify-center space-x-1 sm:space-x-2 text-xs sm:text-sm disabled:opacity-50 min-h-[40px] sm:min-h-[44px]"
                  >
                    <LoaderIcon v-if="isUploadingProfilePicture" class="w-3 h-3 sm:w-4 sm:h-4 animate-spin" />
                    <span v-else>Save</span>
                  </button>
                  <button
                    @click="resetImage"
                    class="flex-1 px-3 sm:px-4 md:px-5 py-1.5 sm:py-2 md:py-2.5 border border-orange-300 text-orange-400 rounded-full hover:bg-gray-50 transition-colors flex items-center justify-center space-x-1 sm:space-x-2 text-xs sm:text-sm min-h-[40px] sm:min-h-[44px]"
                  >
                    <RefreshCcwIcon class="w-3 h-3 sm:w-4 sm:h-4" />
                    <span>Reset</span>
                  </button>
                  <input
                    ref="fileInput"
                    type="file"
                    accept="image/jpeg,image/png,image/gif"
                    class="hidden"
                    @change="handleImageUpload"
                  />
                </div>
                
                <div class="mt-3 sm:mt-4 md:mt-5 text-center">
                  <p class="text-xs sm:text-sm text-gray-500">
                    Allowed JPG, GIF or PNG. Max size of 800K
                  </p>
                </div>
              </div>
            </div>
          </div>

          <!-- Change Password Container -->
          <div class="flex-1 bg-white rounded-xl border border-gray-200 overflow-hidden">
            <div class="p-3 sm:p-4 md:p-6">
              <div class="flex items-center gap-2 sm:gap-3 mb-4 sm:mb-6">
                <KeyIcon class="w-4 h-4 sm:w-5 sm:h-5 text-gray-500" />
                <div>
                  <h2 class="text-lg sm:text-xl font-semibold text-gray-900">Change Password</h2>
                  <p class="text-xs sm:text-sm text-gray-500">To change your password please confirm here</p>
                </div>
              </div>
              
              <form @submit.prevent="updatePassword" class="space-y-3 sm:space-y-4 md:space-y-5">
                <div>
                  <label class="block text-xs sm:text-sm font-medium text-gray-700 mb-2">Current</label>
                  <div class="relative">
                    <input
                      v-model="passwordForm.current"
                      :type="showPassword.current ? 'text' : 'password'"
                      class="block w-full px-3 sm:px-4 py-2 sm:py-2.5 border border-gray-300 rounded-xl text-xs sm:text-sm focus:outline-none focus:ring-1 focus:ring-gray-200"
                    />
                    <button 
                      type="button"
                      @click="togglePassword('current')"
                      class="absolute inset-y-0 right-0 pr-3 flex items-center"
                    >
                      <component 
                        :is="showPassword.current ? EyeOffIcon : EyeIcon"
                        class="h-4 w-4 sm:h-5 sm:w-5 text-gray-400"
                      />
                    </button>
                  </div>
                </div>
                
                <div>
                  <label class="block text-xs sm:text-sm font-medium text-gray-700 mb-2">New Password</label>
                  <div class="relative">
                    <input
                      v-model="passwordForm.new"
                      :type="showPassword.new ? 'text' : 'password'"
                      class="block w-full px-3 sm:px-4 py-2 sm:py-2.5 border border-gray-300 rounded-xl text-xs sm:text-sm focus:outline-none focus:ring-1 focus:ring-gray-200"
                      @input="validatePasswordStrength"
                    />
                    <button 
                      type="button"
                      @click="togglePassword('new')"
                      class="absolute inset-y-0 right-0 pr-3 flex items-center"
                    >
                      <component 
                        :is="showPassword.new ? EyeOffIcon : EyeIcon"
                        class="h-4 w-4 sm:h-5 sm:w-5 text-gray-400"
                      />
                    </button>
                  </div>
                  
                  <!-- Password Strength Indicator -->
                  <div v-if="passwordForm.new" class="mt-2">
                    <div class="flex items-center space-x-2">
                      <div class="flex-1 bg-gray-200 rounded-full h-2 sm:h-6">
                        <div 
                          class="h-2 sm:h-6 rounded-full transition-all duration-300"
                          :class="passwordStrengthColor"
                          :style="{ width: passwordStrengthWidth }"
                        ></div>
                      </div>
                      <span class="text-xs font-medium" :class="passwordStrengthTextColor">
                        {{ passwordStrengthText }}
                      </span>
                    </div>
                    
                    <!-- Password Requirements -->
                    <div class="mt-2 space-y-1">
                      <div class="flex items-center space-x-2">
                        <CheckIcon v-if="passwordRequirements.length" class="h-3 w-3 text-green-500" />
                        <XIcon v-else class="h-3 w-3 text-red-500" />
                        <span class="text-xs" :class="passwordRequirements.length ? 'text-green-600' : 'text-red-600'">
                          At least 8 characters
                        </span>
                      </div>
                      <div class="flex items-center space-x-2">
                        <CheckIcon v-if="passwordRequirements.uppercase" class="h-3 w-3 text-green-500" />
                        <XIcon v-else class="h-3 w-3 text-red-500" />
                        <span class="text-xs" :class="passwordRequirements.uppercase ? 'text-green-600' : 'text-red-600'">
                          One uppercase letter
                        </span>
                      </div>
                      <div class="flex items-center space-x-2">
                        <CheckIcon v-if="passwordRequirements.lowercase" class="h-3 w-3 text-green-500" />
                        <XIcon v-else class="h-3 w-3 text-red-500" />
                        <span class="text-xs" :class="passwordRequirements.lowercase ? 'text-green-600' : 'text-red-600'">
                          One lowercase letter
                        </span>
                      </div>
                      <div class="flex items-center space-x-2">
                        <CheckIcon v-if="passwordRequirements.number" class="h-3 w-3 text-green-500" />
                        <XIcon v-else class="h-3 w-3 text-red-500" />
                        <span class="text-xs" :class="passwordRequirements.number ? 'text-green-600' : 'text-red-600'">
                          One number
                        </span>
                      </div>
                      <div class="flex items-center space-x-2">
                        <CheckIcon v-if="passwordRequirements.special" class="h-3 w-3 text-green-500" />
                        <XIcon v-else class="h-3 w-3 text-red-500" />
                        <span class="text-xs" :class="passwordRequirements.special ? 'text-green-600' : 'text-red-600'">
                          One special character
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
                
                <div>
                  <label class="block text-xs sm:text-sm font-medium text-gray-700 mb-2">Confirm Password</label>
                  <div class="relative">
                    <input
                      v-model="passwordForm.confirm"
                      :type="showPassword.confirm ? 'text' : 'password'"
                      class="block w-full px-3 sm:px-4 py-2 sm:py-2.5 border border-gray-300 rounded-xl text-xs sm:text-sm focus:outline-none focus:ring-1 focus:ring-gray-200"
                      :class="{ 'border-red-300': passwordForm.confirm && !passwordsMatch }"
                    />
                    <button 
                      type="button"
                      @click="togglePassword('confirm')"
                      class="absolute inset-y-0 right-0 pr-3 flex items-center"
                    >
                      <component 
                        :is="showPassword.confirm ? EyeOffIcon : EyeIcon"
                        class="h-4 w-4 sm:h-5 sm:w-5 text-gray-400"
                      />
                    </button>
                  </div>
                  <p v-if="passwordForm.confirm && !passwordsMatch" class="mt-1 text-xs text-red-600">
                    Passwords do not match
                  </p>
                </div>

                <!-- Email Verification Status -->
                <div v-if="!isEmailVerified" class="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
                  <div class="flex items-center">
                    <AlertTriangleIcon class="h-5 w-5 text-yellow-400 mr-2" />
                    <div class="flex-1">
                      <h4 class="text-sm font-medium text-yellow-800">Email Not Verified</h4>
                      <p class="text-sm text-yellow-700 mt-1">
                        Your email address is not verified. You'll need to verify your email before changing your password.
                      </p>
                    </div>
                    <button
                      type="button"
                      @click="sendVerificationEmail"
                      :disabled="verificationEmailSent || sendingVerification"
                      class="ml-4 px-3 py-1 text-xs font-medium text-yellow-800 bg-yellow-100 rounded-md hover:bg-yellow-200 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {{ sendingVerification ? 'Sending...' : verificationEmailSent ? 'Sent!' : 'Send Verification' }}
                    </button>
                  </div>
                </div>

                <button
                  type="submit"
                  class="w-full px-3 sm:px-4 md:px-5 py-2 sm:py-2.5 bg-blue-500 text-white rounded-full hover:bg-blue-600 transition-colors flex items-center justify-center space-x-2 mt-4 sm:mt-6 md:mt-8 text-xs sm:text-sm"
                  :disabled="isUpdating || !canChangePassword"
                >
                  <LoaderIcon v-if="isUpdating" class="w-3 h-3 sm:w-4 sm:h-4 animate-spin" />
                  <span>{{ isUpdating ? 'Updating...' : 'Update Password' }}</span>
                </button>
              </form>
            </div>
          </div>
        </div>

        <!-- Devices Section -->
        <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
          <div class="p-3 sm:p-4 md:p-6">
            <div class="flex items-center gap-2 sm:gap-3 mb-3 sm:mb-4 md:mb-6">
              <MonitorIcon class="w-4 h-4 sm:w-5 sm:h-5 text-gray-500" />
              <div>
                <h2 class="text-lg sm:text-xl font-semibold text-gray-900">Devices</h2>
                <p class="text-xs sm:text-sm text-gray-500">Manage and monitor all devices where your account is signed in.</p>
              </div>
            </div>
            
             <button 
               @click="showSignOutAllConfirmation = true"
               :disabled="isSigningOutAll || devices.filter(d => !d.isCurrent).length === 0"
               class="w-full px-3 sm:px-4 md:px-5 py-2 sm:py-2.5 bg-blue-500 text-white rounded-full hover:bg-blue-600 transition-colors mb-3 sm:mb-4 md:mb-6 text-xs sm:text-sm disabled:opacity-50 flex items-center justify-center space-x-2"
             >
               <LoaderIcon v-if="isSigningOutAll" class="w-3 h-3 sm:w-4 sm:h-4 animate-spin" />
               <span>{{ isSigningOutAll ? 'Signing Out...' : `Sign Out From All Other Devices (${devices.filter(d => !d.isCurrent).length})` }}</span>
             </button>

            <!-- Loading state for devices -->
            <div v-if="isLoadingDevices" class="flex justify-center py-8">
              <LoaderIcon class="w-6 h-6 animate-spin text-gray-400" />
            </div>
            
            <!-- Devices list -->
            <div v-else-if="devices.length > 0" class="space-y-2 sm:space-y-3 md:space-y-4 mt-3 sm:mt-4 md:mt-6">
              <div 
                v-for="device in displayedDevices" 
                :key="device.id"
                class="flex items-start justify-between p-2 sm:p-3 md:p-4 bg-gray-50 rounded-xl"
                :class="{ 
                  'ring-2 ring-blue-200 bg-blue-50': device.isCurrent,
                  'opacity-60': !device.isActive && !device.isCurrent
                }"
              >
                <div class="flex gap-2 sm:gap-3">
                  <component 
                    :is="getDeviceIcon(device.deviceType)" 
                    class="w-4 h-4 sm:w-5 sm:h-5 text-gray-400 mt-1" 
                  />
                  <div>
                    <div class="flex items-center gap-2">
                      <p class="text-xs sm:text-sm font-medium">{{ device.deviceName }}</p>
                      <span v-if="device.isCurrent" class="px-2 py-1 text-xs bg-green-100 text-green-800 rounded-full">
                        Current
                      </span>
                      <span v-else-if="!device.isActive" class="px-2 py-1 text-xs bg-gray-100 text-gray-600 rounded-full">
                        Inactive
                      </span>
                    </div>
                    <p class="text-xs sm:text-sm text-gray-500">
                      {{ device.location }} • {{ formatLastActive(device.lastActive) }}
                    </p>
                    <p class="text-xs text-gray-400">
                      {{ device.browser }}{{ device.browserVersion ? ` ${device.browserVersion}` : '' }} • {{ device.os }}{{ device.osVersion ? ` ${device.osVersion}` : '' }}
                    </p>
                    <p v-if="device.lastLogin" class="text-xs text-blue-500">
                      {{ formatLoginTime(device.lastLogin) }}
                      <span v-if="device.loginCount > 1" class="text-gray-400"> • {{ device.loginCount }} logins</span>
                    </p>
                  </div>
                </div>
                <div class="relative">
                  <button 
                    @click="toggleDeviceMenu(device.id)"
                    class="text-gray-400 hover:text-gray-600 p-1"
                  >
                    <MoreVerticalIcon class="w-4 h-4 sm:w-5 sm:h-5" />
                  </button>
                  
                  <!-- Device menu dropdown -->
                  <div 
                    v-if="activeDeviceMenu === device.id"
                    class="absolute right-0 top-8 bg-white border border-gray-200 rounded-lg shadow-lg z-10 min-w-[120px]"
                  >
                    <button
                      v-if="!device.isCurrent"
                      @click="confirmSignOutDevice(device)"
                      :disabled="signingOutDevices.includes(device.id)"
                      class="w-full text-left px-3 py-2 text-xs text-red-600 hover:bg-red-50 rounded-lg disabled:opacity-50"
                    >
                      {{ signingOutDevices.includes(device.id) ? 'Signing Out...' : 'Sign Out' }}
                    </button>
                    <button
                      @click="viewDeviceDetails(device)"
                      class="w-full text-left px-3 py-2 text-xs text-gray-700 hover:bg-gray-50 rounded-lg"
                    >
                      View Details
                    </button>
                  </div>
                </div>
              </div>
              
              <!-- Show More/Less button -->
              <div v-if="devices.length > 3" class="flex justify-center pt-2 sm:pt-3">
                <button
                  @click="toggleShowAllDevices"
                  class="flex items-center space-x-2 px-4 py-2 text-sm font-medium text-blue-600 hover:text-blue-700 hover:bg-blue-50 rounded-lg transition-colors"
                >
                  <span>{{ showAllDevices ? 'Show Less' : 'Show More' }}</span>
                  <ChevronDownIcon 
                    class="w-4 h-4 transition-transform duration-200"
                    :class="{ 'rotate-180': showAllDevices }"
                  />
                </button>
              </div>
            </div>
            
            <!-- Empty state -->
            <div v-else class="text-center py-8">
              <MonitorIcon class="w-12 h-12 text-gray-300 mx-auto mb-4" />
              <p class="text-sm text-gray-500">No devices found</p>
            </div>

            <div class="mt-4 sm:mt-6 md:mt-8 text-center">
              <button @click="openHelpModal" class="text-xs sm:text-sm text-blue-500 hover:text-blue-600 underline">Need Help?</button>
            </div>
          </div>
        </div>
        
        <!-- Delete Account Section (Danger Zone) -->
        <div class="bg-white rounded-xl border border-red-100 overflow-hidden">
          <div class="p-3 sm:p-4 md:p-6">
            <div class="flex items-center gap-2 sm:gap-3 mb-3 sm:mb-4 md:mb-6">
              <AlertTriangleIcon class="w-4 h-4 sm:w-5 sm:h-5 text-red-500" />
              <div>
                <h2 class="text-lg sm:text-xl font-semibold text-gray-900">Delete Account</h2>
                <p class="text-xs sm:text-sm text-gray-500">Once you delete your account, there is no going back. Please be certain.</p>
              </div>
            </div>
            
            <div class="flex flex-col md:flex-row items-center justify-between gap-3 sm:gap-4">
              <div class="text-xs sm:text-sm text-gray-600 max-w-lg">
                <p>Deleting your account will:</p>
                <ul class="list-disc ml-4 sm:ml-5 mt-2 space-y-1">
                  <li>Remove all your personal information</li>
                  <li>Delete all your data and content</li>
                </ul>
              </div>
              
              <button
                @click="showDeleteConfirmation = true; preventBodyScroll()"
                class="w-full md:w-auto px-3 sm:px-4 md:px-5 py-2 sm:py-2.5 bg-red-500 text-white rounded-full hover:bg-red-600 transition-colors flex items-center justify-center md:justify-start space-x-2 mt-3 sm:mt-4 md:mt-0 text-xs sm:text-sm"
              >
                <TrashIcon class="w-3 h-3 sm:w-4 sm:h-4" />
                <span>Delete Account</span>
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Notification Tab Content - Improved with only Push Notification -->
      <div v-if="currentTab === 'notification'" class="bg-white rounded-xl border border-gray-200 overflow-hidden">
        <div class="p-3 sm:p-4 md:p-6">
          <div class="flex items-center gap-2 sm:gap-3 mb-3 sm:mb-4 md:mb-6">
            <BellIcon class="w-4 h-4 sm:w-5 sm:h-5 text-gray-500" />
            <div>
              <h2 class="text-lg sm:text-xl font-semibold text-gray-900">Notification Settings</h2>
              <p class="text-xs sm:text-sm text-gray-500">Manage your notification preferences</p>
            </div>
          </div>
          
          <div class="space-y-3 sm:space-y-4 md:space-y-5">
            <div class="flex items-center justify-between py-2 sm:py-3 md:py-4 border-b border-gray-200">
              <div>
                <h3 class="text-xs sm:text-sm font-medium text-gray-900">Push Notifications</h3>
                <p class="text-xs sm:text-sm text-gray-500">Receive push notifications</p>
              </div>
              <div class="flex items-center gap-2 sm:gap-3">
                <span v-if="notificationSaved" class="text-xs text-green-500 animate-fade-out">
                  <CheckIcon class="w-3 h-3 sm:w-4 sm:h-4 inline" /> Saved
                </span>
                <label class="flex items-center cursor-pointer">
                  <div class="relative">
                    <input 
                      type="checkbox" 
                      v-model="pushNotificationEnabled" 
                      class="sr-only" 
                      @change="autoSaveNotification"
                    />
                    <div 
                      class="block w-10 sm:w-12 h-5 sm:h-6 rounded-full transition-colors duration-200" 
                      :class="pushNotificationEnabled ? 'bg-blue-500' : 'bg-gray-300'"
                    ></div>
                    <div 
                      class="absolute left-1 top-1 w-3 sm:w-4 h-3 sm:h-4 bg-white rounded-full transition-transform duration-200 transform"
                      :class="pushNotificationEnabled ? 'translate-x-5 sm:translate-x-6' : 'translate-x-0'"
                    ></div>
                  </div>
                </label>
              </div>
            </div>
          </div>
          
          <div class="mt-4 sm:mt-6 md:mt-8 flex justify-end">
            <button
              @click="saveNotificationSettings"
              class="px-3 sm:px-4 md:px-5 py-2 sm:py-2.5 bg-blue-500 text-white rounded-full hover:bg-blue-600 transition-colors flex items-center space-x-2 text-xs sm:text-sm"
              :disabled="isSavingNotifications"
            >
              <LoaderIcon v-if="isSavingNotifications" class="w-3 h-3 sm:w-4 sm:h-4 animate-spin" />
              <span>{{ isSavingNotifications ? 'Saving...' : 'Save Settings' }}</span>
            </button>
          </div>
        </div>
      </div>



            </div>
          </div>
          
  <!-- Delete Account Confirmation Modal -->
  <div v-if="showDeleteConfirmation" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-2 sm:p-4" @click="preventModalClose">
    <div class="bg-white rounded-xl max-w-xs sm:max-w-md w-full p-3 sm:p-4 md:p-6" @click="preventModalClose">
      <div class="text-center mb-3 sm:mb-4 md:mb-6">
        <AlertCircleIcon class="w-8 h-8 sm:w-10 sm:h-10 md:w-12 md:h-12 text-red-500 mx-auto mb-2 sm:mb-3 md:mb-4" />
        <h3 class="text-base sm:text-lg md:text-xl font-bold text-gray-900">Delete Account</h3>
        <p class="text-xs sm:text-sm text-gray-600 mt-1 sm:mt-2">Are you sure you want to delete your account? This action cannot be undone.</p>
      </div>
      
      <div class="mb-3 sm:mb-4 md:mb-6">
        <label class="block text-xs sm:text-sm font-medium text-gray-700 mb-1 sm:mb-2">Type "delete" to confirm</label>
        <input
          v-model="deleteConfirmText"
          type="text"
          class="block w-full px-2 sm:px-3 md:px-4 py-1.5 sm:py-2 md:py-2.5 border border-gray-300 rounded-xl text-xs sm:text-sm focus:outline-none focus:ring-1 focus:ring-gray-200"
          placeholder="delete"
        />
                </div>
      
      <div class="flex space-x-2 sm:space-x-3 md:space-x-4">
        <button
          @click="showDeleteConfirmation = false; restoreBodyScroll()"
          class="flex-1 px-2 sm:px-3 md:px-4 py-1.5 sm:py-2 md:py-2.5 border border-gray-300 text-gray-700 rounded-full hover:bg-gray-50 transition-colors text-xs sm:text-sm"
        >
          Cancel
        </button>
        <button
          @click="deleteAccount"
          :disabled="deleteConfirmText !== 'delete'"
          class="flex-1 px-2 sm:px-3 md:px-4 py-1.5 sm:py-2 md:py-2.5 bg-red-500 text-white rounded-full hover:bg-red-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed text-xs sm:text-sm"
        >
          Delete
              </button>
            </div>
                </div>
              </div>

  <!-- Sign Out Device Confirmation Modal -->
  <div v-if="showSignOutDeviceConfirmation" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4" @click="preventModalClose">
    <div class="bg-white rounded-xl max-w-md w-full p-4 sm:p-6" @click="preventModalClose">
      <div class="text-center mb-4 sm:mb-6">
        <AlertCircleIcon class="w-10 h-10 sm:w-12 sm:h-12 text-orange-500 mx-auto mb-3 sm:mb-4" />
        <h3 class="text-lg sm:text-xl font-bold text-gray-900">Sign Out Device</h3>
        <p class="text-xs sm:text-sm text-gray-600 mt-2">
          Are you sure you want to sign out from "{{ deviceToSignOut?.deviceName }}"? 
          This will end the session on that device.
        </p>
      </div>
      
      <div class="flex space-x-3 sm:space-x-4">
        <button
          @click="showSignOutDeviceConfirmation = false; restoreBodyScroll()"
          class="flex-1 px-3 sm:px-4 py-2 sm:py-2.5 border border-gray-300 text-gray-700 rounded-full hover:bg-gray-50 transition-colors text-xs sm:text-sm"
        >
          Cancel
        </button>
        <button
          @click="signOutDevice(deviceToSignOut.id)"
          class="flex-1 px-3 sm:px-4 py-2 sm:py-2.5 bg-red-500 text-white rounded-full hover:bg-red-600 transition-colors text-xs sm:text-sm"
        >
          Sign Out
              </button>
      </div>
            </div>
          </div>

  <!-- Sign Out All Devices Confirmation Modal -->
  <div v-if="showSignOutAllConfirmation" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4" @click="preventModalClose">
    <div class="bg-white rounded-xl max-w-md w-full p-4 sm:p-6" @click="preventModalClose">
      <div class="text-center mb-4 sm:mb-6">
        <AlertCircleIcon class="w-10 h-10 sm:w-12 sm:h-12 text-orange-500 mx-auto mb-3 sm:mb-4" />
        <h3 class="text-lg sm:text-xl font-bold text-gray-900">Sign Out All Devices</h3>
        <p class="text-xs sm:text-sm text-gray-600 mt-2">
          This will sign you out from all other devices except this one. You'll need to sign in again on those devices.
        </p>
        <div class="mt-4 p-3 bg-yellow-50 rounded-lg">
          <p class="text-xs text-yellow-800">
            <strong>{{ devices.filter(d => !d.isCurrent).length }}</strong> other device(s) will be signed out.
          </p>
          </div>
        </div>
      
      <div class="flex space-x-3 sm:space-x-4">
        <button
          @click="showSignOutAllConfirmation = false; restoreBodyScroll()"
          class="flex-1 px-3 sm:px-4 py-2 sm:py-2.5 border border-gray-300 text-gray-700 rounded-full hover:bg-gray-50 transition-colors text-xs sm:text-sm"
        >
          Cancel
        </button>
        <button
          @click="signOutFromAllDevices"
          class="flex-1 px-3 sm:px-4 py-2 sm:py-2.5 bg-red-500 text-white rounded-full hover:bg-red-600 transition-colors text-xs sm:text-sm"
        >
          Sign Out All
        </button>
      </div>
    </div>
  </div>

  <!-- Device Details Modal -->
  <div v-if="showDeviceDetails" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-2 sm:p-4" @click="preventModalClose">
    <div class="bg-white rounded-xl max-w-xs sm:max-w-md w-full max-h-[90vh] overflow-y-auto p-3 sm:p-4 md:p-6" @click="preventModalClose">
      <div class="flex items-center justify-between mb-3 sm:mb-4">
        <h3 class="text-base sm:text-lg font-semibold text-gray-900">Device Details</h3>
        <button @click="showDeviceDetails = false; restoreBodyScroll()" class="text-gray-400 hover:text-gray-600">
          <XIcon class="w-4 h-4 sm:w-5 sm:h-5" />
        </button>
      </div>
      
      <div v-if="selectedDevice" class="space-y-3 sm:space-y-4">
        <div>
          <label class="text-xs sm:text-sm font-medium text-gray-700">Device Name</label>
          <p class="text-xs sm:text-sm text-gray-900">{{ selectedDevice.deviceName }}</p>
        </div>
        <div>
          <label class="text-xs sm:text-sm font-medium text-gray-700">Browser</label>
          <p class="text-xs sm:text-sm text-gray-900">{{ selectedDevice.browser }}{{ selectedDevice.browserVersion ? ` ${selectedDevice.browserVersion}` : '' }}</p>
        </div>
        <div>
          <label class="text-xs sm:text-sm font-medium text-gray-700">Operating System</label>
          <p class="text-xs sm:text-sm text-gray-900">{{ selectedDevice.os }}{{ selectedDevice.osVersion ? ` ${selectedDevice.osVersion}` : '' }}</p>
        </div>
        <div>
          <label class="text-xs sm:text-sm font-medium text-gray-700">IP Address</label>
          <p class="text-xs sm:text-sm text-gray-900">{{ selectedDevice.ipAddress }}</p>
        </div>
        <div>
          <label class="text-xs sm:text-sm font-medium text-gray-700">Location</label>
          <p class="text-xs sm:text-sm text-gray-900">{{ selectedDevice.location }}</p>
        </div>
        <div>
          <label class="text-xs sm:text-sm font-medium text-gray-700">Last Active</label>
          <p class="text-xs sm:text-sm text-gray-900">{{ formatLastActive(selectedDevice.lastActive) }}</p>
        </div>
        <div v-if="selectedDevice.lastLogin">
          <label class="text-xs sm:text-sm font-medium text-gray-700">Last Login</label>
          <p class="text-xs sm:text-sm text-gray-900">{{ formatDate(selectedDevice.lastLogin) }}</p>
        </div>
        <div>
          <label class="text-xs sm:text-sm font-medium text-gray-700">First Login</label>
          <p class="text-xs sm:text-sm text-gray-900">{{ formatDate(selectedDevice.firstLogin) }}</p>
        </div>
        <div v-if="selectedDevice.loginCount">
          <label class="text-xs sm:text-sm font-medium text-gray-700">Total Logins</label>
          <p class="text-xs sm:text-sm text-gray-900">{{ selectedDevice.loginCount }}</p>
        </div>
        <div>
          <label class="text-xs sm:text-sm font-medium text-gray-700">Session Status</label>
          <p class="text-xs sm:text-sm text-gray-900">
            <span :class="selectedDevice.isActive ? 'text-green-600' : 'text-red-600'">
              {{ selectedDevice.isActive ? 'Active' : 'Inactive' }}
            </span>
            <span v-if="selectedDevice.isCurrent" class="ml-2 text-blue-600">(Current Session)</span>
          </p>
        </div>
      </div>
    </div>
      </div>
      
  <!-- Success Modal -->
  <div v-if="showSuccessModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4" @click="preventModalClose">
    <div class="bg-white rounded-xl shadow-xl max-w-sm w-full mx-auto p-6" @click="preventModalClose">
      <div class="flex items-center justify-center w-12 h-12 rounded-full bg-green-100 mx-auto mb-4">
        <CheckIcon class="h-6 w-6 text-green-600" />
      </div>
      <h3 class="text-lg font-medium text-center text-gray-900 mb-2">Success</h3>
      <p class="text-sm text-gray-500 text-center mb-6">
        {{ statusMessage }}
      </p>
      <div class="flex justify-center">
        <button
          @click="showSuccessModal = false; restoreBodyScroll()"
          class="px-4 py-2 border border-transparent rounded-full shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700"
        >
          OK
        </button>
      </div>
    </div>
  </div>

  <!-- Error Modal -->
  <div v-if="showErrorModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4" @click="preventModalClose">
    <div class="bg-white rounded-xl shadow-xl max-w-sm w-full mx-auto p-6" @click="preventModalClose">
      <div class="flex items-center justify-center w-12 h-12 rounded-full bg-red-100 mx-auto mb-4">
        <XIcon class="h-6 w-6 text-red-600" />
      </div>
      <h3 class="text-lg font-medium text-center text-gray-900 mb-2">Error</h3>
      <p class="text-sm text-gray-500 text-center mb-6">
        {{ errorMessage }}
      </p>
      <div class="flex justify-center">
        <button
          @click="showErrorModal = false; restoreBodyScroll()"
          class="px-4 py-2 border border-transparent rounded-full shadow-sm text-sm font-medium text-white bg-red-600 hover:bg-red-700"
        >
          OK
        </button>
      </div>
    </div>
  </div>

  <!-- Help Modal -->
  <div v-if="showHelpModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-2 sm:p-4" @click="preventModalClose">
    <div class="bg-white rounded-xl shadow-xl max-w-xs sm:max-w-2xl md:max-w-3xl lg:max-w-4xl w-full max-h-[95vh] sm:max-h-[90vh] overflow-hidden flex flex-col" @click="preventModalClose">
      <!-- Header -->
      <div class="flex items-center justify-between p-3 sm:p-4 md:p-6 border-b border-gray-200 flex-shrink-0">
        <div class="flex items-center space-x-2 sm:space-x-3 min-w-0 flex-1">
          <div class="w-6 h-6 sm:w-8 sm:h-8 bg-blue-100 rounded-lg flex items-center justify-center flex-shrink-0">
            <MonitorIcon class="w-4 h-4 sm:w-5 sm:h-5 text-blue-600" />
          </div>
          <div class="min-w-0 flex-1">
            <h2 class="text-base sm:text-lg md:text-xl font-semibold text-gray-900">Device Management Help</h2>
            <p class="text-xs sm:text-sm text-gray-500">Learn how to manage your device sessions</p>
          </div>
        </div>
        <button @click="closeHelpModal" class="p-1.5 sm:p-2 rounded-full hover:bg-gray-100 transition-colors flex-shrink-0">
          <XIcon class="w-4 h-4 sm:w-5 sm:h-5 text-gray-500" />
        </button>
      </div>

      <!-- Content -->
      <div class="flex-1 overflow-y-auto p-3 sm:p-4 md:p-6">
        <div class="space-y-4 sm:space-y-5 md:space-y-6">
          <!-- Understanding Device Sessions -->
          <div class="bg-blue-50 rounded-lg p-3 sm:p-4 md:p-5">
            <div class="flex items-start space-x-2 sm:space-x-3">
              <div class="w-5 h-5 sm:w-6 sm:h-6 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                <span class="text-blue-600 text-xs sm:text-sm font-semibold">1</span>
              </div>
              <div class="min-w-0 flex-1">
                <h3 class="text-sm sm:text-base md:text-lg font-semibold text-gray-900 mb-2">Understanding Device Sessions</h3>
                <div class="space-y-1 sm:space-y-2 text-xs sm:text-sm text-gray-700">
                  <p class="leading-relaxed">• Each browser/device combination creates a separate session</p>
                  <p class="leading-relaxed">• Sessions track when and where you log in</p>
                  <p class="leading-relaxed">• Your current session is highlighted in blue with a "Current" badge</p>
                  <p class="leading-relaxed">• Only the latest 3 devices are shown by default</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Security Best Practices -->
          <div class="bg-green-50 rounded-lg p-3 sm:p-4 md:p-5">
            <div class="flex items-start space-x-2 sm:space-x-3">
              <div class="w-5 h-5 sm:w-6 sm:h-6 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                <span class="text-green-600 text-xs sm:text-sm font-semibold">2</span>
              </div>
              <div class="min-w-0 flex-1">
                <h3 class="text-sm sm:text-base md:text-lg font-semibold text-gray-900 mb-2">Security Best Practices</h3>
                <div class="space-y-1 sm:space-y-2 text-xs sm:text-sm text-gray-700">
                  <p class="leading-relaxed">• Sign out from devices you don't recognize</p>
                  <p class="leading-relaxed">• Regularly review your active sessions</p>
                  <p class="leading-relaxed">• Use "Sign Out All Other Devices" if you suspect unauthorized access</p>
                  <p class="leading-relaxed">• Check device details to verify location and browser information</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Common Questions -->
          <div class="bg-yellow-50 rounded-lg p-3 sm:p-4 md:p-5">
            <div class="flex items-start space-x-2 sm:space-x-3">
              <div class="w-5 h-5 sm:w-6 sm:h-6 bg-yellow-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                <span class="text-yellow-600 text-xs sm:text-sm font-semibold">3</span>
              </div>
              <div class="min-w-0 flex-1">
                <h3 class="text-sm sm:text-base md:text-lg font-semibold text-gray-900 mb-2">Common Questions</h3>
                <div class="space-y-2 sm:space-y-3 text-xs sm:text-sm text-gray-700">
                  <div>
                    <p class="font-medium text-gray-900 leading-relaxed">Q: Why do I see my phone twice?</p>
                    <p class="text-gray-600 leading-relaxed">A: Different browsers (Chrome vs Safari) create separate sessions.</p>
                  </div>
                  <div>
                    <p class="font-medium text-gray-900 leading-relaxed">Q: What happens when I sign out from a device?</p>
                    <p class="text-gray-600 leading-relaxed">A: You'll need to log in again on that device. Your current session remains active.</p>
                  </div>
                  <div>
                    <p class="font-medium text-gray-900 leading-relaxed">Q: Why can't I see all my devices?</p>
                    <p class="text-gray-600 leading-relaxed">A: Click "Show More" to see all devices. Only the latest 3 are shown by default.</p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Troubleshooting -->
          <div class="bg-purple-50 rounded-lg p-3 sm:p-4 md:p-5">
            <div class="flex items-start space-x-2 sm:space-x-3">
              <div class="w-5 h-5 sm:w-6 sm:h-6 bg-purple-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                <span class="text-purple-600 text-xs sm:text-sm font-semibold">4</span>
              </div>
              <div class="min-w-0 flex-1">
                <h3 class="text-sm sm:text-base md:text-lg font-semibold text-gray-900 mb-2">Troubleshooting</h3>
                <div class="space-y-1 sm:space-y-2 text-xs sm:text-sm text-gray-700">
                  <p class="leading-relaxed">• Can't see a device? Try refreshing the page</p>
                  <p class="leading-relaxed">• Device shows wrong location? Location is approximate based on IP</p>
                  <p class="leading-relaxed">• Session won't sign out? Try again in a few minutes</p>
                  <p class="leading-relaxed">• Duplicate devices? They're automatically cleaned up</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Device Information -->
          <div class="bg-gray-50 rounded-lg p-3 sm:p-4 md:p-5">
            <div class="flex items-start space-x-2 sm:space-x-3">
              <div class="w-5 h-5 sm:w-6 sm:h-6 bg-gray-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                <span class="text-gray-600 text-xs sm:text-sm font-semibold">5</span>
              </div>
              <div class="min-w-0 flex-1">
                <h3 class="text-sm sm:text-base md:text-lg font-semibold text-gray-900 mb-2">Device Information</h3>
                <div class="space-y-1 sm:space-y-2 text-xs sm:text-sm text-gray-700">
                  <p class="leading-relaxed">• <strong>Device Name:</strong> Browser and operating system</p>
                  <p class="leading-relaxed">• <strong>Location:</strong> Approximate city and country</p>
                  <p class="leading-relaxed">• <strong>Last Active:</strong> When the device was last used</p>
                  <p class="leading-relaxed">• <strong>IP Address:</strong> Network identifier (for security)</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Footer -->
      <div class="flex flex-col sm:flex-row items-center justify-between gap-3 p-3 sm:p-4 md:p-6 border-t border-gray-200 flex-shrink-0">
        <div class="text-xs sm:text-sm text-gray-500 text-center sm:text-left">
          Still need help? Contact our support team.
        </div>
        <button @click="closeHelpModal" class="w-full sm:w-auto px-4 sm:px-5 py-2 sm:py-2.5 bg-blue-500 text-white rounded-full hover:bg-blue-600 transition-colors text-xs sm:text-sm font-medium">
          Got it!
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { 
  UserIcon, 
  BellIcon, 
  ShieldIcon,
  UploadIcon,
  RefreshCcwIcon,
  EyeIcon,
  EyeOffIcon,
  LoaderIcon,
  MonitorIcon,
  SmartphoneIcon,
  LaptopIcon,
  TabletIcon,
  MoreVerticalIcon,
  KeyIcon,
  AlertTriangleIcon,
  TrashIcon,
  AlertCircleIcon,
  CheckIcon,
  X as XIcon,
  ChevronDownIcon
} from 'lucide-vue-next'
import { useAuthStore } from '@/stores/modules/authStore'
import { useProfileStore } from '@/stores/modules/profileStore'

// Import Firebase Auth functions
import { 
  updatePassword as firebaseUpdatePassword, 
  reauthenticateWithCredential, 
  EmailAuthProvider,
  sendEmailVerification,
  reload,
  signOut
} from 'firebase/auth'
import { auth } from '@shared/firebase'

// Import Firestore functions
import { doc, getDoc, collection, addDoc, query, where, getDocs, deleteDoc, updateDoc, serverTimestamp } from 'firebase/firestore'
import { db } from '@shared/firebase'

// Import Firebase Storage functions
import { ref as storageRef, uploadBytes, getDownloadURL } from 'firebase/storage'
import { storage } from '@shared/firebase'


const router = useRouter()
const authStore = useAuthStore()
const profileStore = useProfileStore()

const tabs = [
  { id: 'account', name: 'Account & Security', icon: ShieldIcon },
  { id: 'notification', name: 'Notification', icon: BellIcon }
]

const currentTab = ref('account')
const profileImage = ref(null)
const isUpdating = ref(false)

// Profile picture upload states
const selectedProfilePicture = ref(null)
const isUploadingProfilePicture = ref(false)
const photoChanged = ref(false)
const fileInput = ref(null)

// Add the SVG placeholder
const profilePlaceholder = ref('data:image/svg+xml,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' width=\'36\' height=\'36\' viewBox=\'0 0 36 36\'%3E%3Crect width=\'36\' height=\'36\' fill=\'%23f0f2f5\'/%3E%3Cpath d=\'M18 20.5a5.5 5.5 0 1 0 0-11 5.5 5.5 0 0 0 0 11ZM8 28.5c0-2.5 5-5 10-5s10 2.5 10 5\' stroke=\'%23bec3c9\' stroke-width=\'2\' fill=\'none\'/%3E%3C/svg%3E')

// Computed property for current profile picture with fallback chain
const currentProfilePicture = computed(() => {
  const profilePhoto = profileStore.profile?.photoURL
  const authPhoto = authStore.user?.photoURL
  const defaultPhoto = profilePlaceholder.value
  return profilePhoto || authPhoto || defaultPhoto
})

const passwordForm = ref({
  current: '',
  new: '',
  confirm: ''
})

const showPassword = ref({
  current: false,
  new: false,
  confirm: false
})

// Password strength validation
const passwordRequirements = ref({
  length: false,
  uppercase: false,
  lowercase: false,
  number: false,
  special: false
})

// Delete account related refs
const showDeleteConfirmation = ref(false)
const deleteConfirmText = ref('')

// Notification settings
const pushNotificationEnabled = ref(false)
const notificationSaved = ref(false)
const isSavingNotifications = ref(false)

// Email verification
const verificationEmailSent = ref(false)
const sendingVerification = ref(false)

// Modals
const showSuccessModal = ref(false)
const showErrorModal = ref(false)
const statusMessage = ref('')
const errorMessage = ref('')

// User data from Firestore
const userData = ref(null)

// Add loading state
const isLoadingUserData = ref(true)

// Device management states
const devices = ref([])
const isLoadingDevices = ref(true)
const isSigningOutAll = ref(false)
const signingOutDevices = ref([])
const activeDeviceMenu = ref(null)
const showDeviceDetails = ref(false)
const selectedDevice = ref(null)
const currentSessionId = ref(null)

// New confirmation modals
const showSignOutDeviceConfirmation = ref(false)
const showSignOutAllConfirmation = ref(false)
const deviceToSignOut = ref(null)

// Device list toggle
const showAllDevices = ref(false)

// Help modal
const showHelpModal = ref(false)

// Computed property for displayed devices
const displayedDevices = computed(() => {
  if (showAllDevices.value) {
    return devices.value
  }
  return devices.value.slice(0, 3)
})

// Computed property to check email verification from both Firebase Auth and Firestore
const isEmailVerified = computed(() => {
  // Check Firebase Auth first
  const firebaseAuthVerified = authStore.user?.emailVerified || false
  
  // Check Firestore document
  const firestoreVerified = userData.value?.emailVerified || false
  
  // Return true if either source shows verification
  const verified = firebaseAuthVerified || firestoreVerified
  
  return verified
})

// Computed properties for password validation
const passwordsMatch = computed(() => {
  return passwordForm.value.new === passwordForm.value.confirm
})

const passwordStrength = computed(() => {
  const password = passwordForm.value.new
  let score = 0

  if (password.length >= 8) score++
  if (/[A-Z]/.test(password)) score++
  if (/[a-z]/.test(password)) score++
  if (/\d/.test(password)) score++
  if (/[!@#$%^&*(),.?":{}|<>]/.test(password)) score++

  return score
})

const passwordStrengthText = computed(() => {
  const strength = passwordStrength.value
  if (strength === 0) return 'Very Weak'
  if (strength === 1) return 'Weak'
  if (strength === 2) return 'Fair'
  if (strength === 3) return 'Good'
  if (strength === 4) return 'Strong'
  return 'Very Strong'
})

const passwordStrengthColor = computed(() => {
  const strength = passwordStrength.value
  if (strength <= 1) return 'bg-red-500'
  if (strength === 2) return 'bg-yellow-500'
  if (strength === 3) return 'bg-blue-500'
  if (strength >= 4) return 'bg-green-500'
  return 'bg-gray-300'
})

const passwordStrengthTextColor = computed(() => {
  const strength = passwordStrength.value
  if (strength <= 1) return 'text-red-600'
  if (strength === 2) return 'text-yellow-600'
  if (strength === 3) return 'text-blue-600'
  if (strength >= 4) return 'text-green-600'
  return 'text-gray-600'
})

const passwordStrengthWidth = computed(() => {
  return `${(passwordStrength.value / 5) * 100}%`
})

const canChangePassword = computed(() => {
  return passwordForm.value.current &&
         passwordForm.value.new &&
         passwordForm.value.confirm &&
         passwordsMatch.value &&
         passwordStrength.value >= 3 &&
         isEmailVerified.value
})

// Generate a unique session ID for this browser session
const generateSessionId = () => {
  return Date.now().toString(36) + Math.random().toString(36).substr(2)
}

// Get device information
const getDeviceInfo = () => {
  const userAgent = navigator.userAgent
  const platform = navigator.platform
  
  // Detect device type with more accuracy
  let deviceType = 'desktop'
  if (/Mobile|Android|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/.test(userAgent)) {
    if (/iPad|Tablet/.test(userAgent)) {
      deviceType = 'tablet'
    } else {
      deviceType = 'mobile'
    }
  }
  
  // Detect browser with comprehensive detection logic (same as welcomeNotificationService.js)
  let browser = 'Unknown'
  let browserVersion = 'Unknown'
  
  // Detect Edge (Chromium-based) - must check first before Chrome
  if (userAgent.indexOf('Edg') !== -1) {
    browser = 'Edge'
    const edgMatch = userAgent.match(/(Edg|Edge)\/([0-9]+\.[0-9]+)/)
    browserVersion = edgMatch ? edgMatch[2] : 'Unknown'
  }
  // Detect Chrome (but not Edge or Opera)
  else if (userAgent.indexOf('Chrome') !== -1 && userAgent.indexOf('OPR') === -1 && userAgent.indexOf('Edg') === -1) {
    browser = 'Chrome'
    const chromeMatch = userAgent.match(/Chrome\/([0-9]+\.[0-9]+)/)
    browserVersion = chromeMatch ? chromeMatch[1] : 'Unknown'
  }
  // Detect Firefox
  else if (userAgent.indexOf('Firefox') !== -1) {
    browser = 'Firefox'
    const ffMatch = userAgent.match(/Firefox\/([0-9]+\.[0-9]+)/)
    browserVersion = ffMatch ? ffMatch[1] : 'Unknown'
  }
  // Detect Safari (but not Chrome)
  else if (userAgent.indexOf('Safari') !== -1 && userAgent.indexOf('Chrome') === -1) {
    browser = 'Safari'
    const safariMatch = userAgent.match(/Version\/([0-9]+\.[0-9]+)/)
    browserVersion = safariMatch ? safariMatch[1] : 'Unknown'
  }
  // Detect Opera
  else if (userAgent.indexOf('OPR') !== -1) {
    browser = 'Opera'
    const operaMatch = userAgent.match(/OPR\/([0-9]+\.[0-9]+)/)
    browserVersion = operaMatch ? operaMatch[1] : 'Unknown'
  }
  // Detect mobile browsers
  else if (/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(userAgent)) {
    browser = 'Mobile Browser'
    if (userAgent.indexOf('Android') !== -1) {
      browser = 'Android Browser'
    } else if (userAgent.indexOf('iPhone') !== -1 || userAgent.indexOf('iPad') !== -1) {
      browser = 'Mobile Safari'
    }
  }
  
  // Detect OS with more accuracy
  let os = 'Unknown'
  let osVersion = ''
  
  if (userAgent.includes('Windows NT')) {
    os = 'Windows'
    const match = userAgent.match(/Windows NT (\d+\.\d+)/)
    if (match) {
      const version = match[1]
      if (version === '10.0') osVersion = '10/11'
      else if (version === '6.3') osVersion = '8.1'
      else if (version === '6.2') osVersion = '8'
      else if (version === '6.1') osVersion = '7'
      else osVersion = version
    }
  } else if (userAgent.includes('Mac OS X')) {
    os = 'macOS'
    const match = userAgent.match(/Mac OS X (\d+[._]\d+)/)
    if (match) {
      osVersion = match[1].replace('_', '.')
    }
  } else if (userAgent.includes('Linux')) {
    os = 'Linux'
    if (userAgent.includes('Ubuntu')) osVersion = 'Ubuntu'
    else if (userAgent.includes('Fedora')) osVersion = 'Fedora'
    else if (userAgent.includes('Debian')) osVersion = 'Debian'
    else if (userAgent.includes('CentOS')) osVersion = 'CentOS'
  } else if (userAgent.includes('Android')) {
    os = 'Android'
    const match = userAgent.match(/Android (\d+\.\d+)/)
    if (match) osVersion = match[1]
  } else if (userAgent.includes('iPhone') || userAgent.includes('iPad') || userAgent.includes('iPod')) {
    os = 'iOS'
    const match = userAgent.match(/OS (\d+[._]\d+)/)
    if (match) {
      osVersion = match[1].replace('_', '.')
    }
  }
  
  // Generate device name with version info
  let deviceName = browser
  if (browserVersion) {
    deviceName += ` ${browserVersion}`
  }
  deviceName += ` on ${os}`
  if (osVersion) {
    deviceName += ` ${osVersion}`
  }
  
  // Adjust for mobile/tablet
  if (deviceType === 'mobile') {
    deviceName = `${browser} Mobile`
    if (browserVersion) deviceName += ` ${browserVersion}`
  } else if (deviceType === 'tablet') {
    deviceName = `${browser} Tablet`
    if (browserVersion) deviceName += ` ${browserVersion}`
  }
  
  return {
    deviceType,
    browser,
    browserVersion,
    os,
    osVersion,
    deviceName,
    userAgent
  }
}

// Get user's location (simplified - you might want to use a proper geolocation service)
const getUserLocation = async () => {
  try {
    // This is a simplified location detection
    // In production, you'd use a service like ipapi.co or similar
    const response = await fetch('https://ipapi.co/json/')
    const data = await response.json()
    return `${data.city}, ${data.country_name}`
  } catch (error) {
    return 'Unknown Location'
  }
}

const togglePassword = (field) => {
  showPassword.value[field] = !showPassword.value[field]
}

// Register current device session
const registerDeviceSession = async () => {
  if (!authStore.user?.uid) return
  
  try {
    const deviceInfo = getDeviceInfo()
    const location = await getUserLocation()
    
    // Get IP address (simplified)
    let ipAddress = 'Unknown'
    try {
      const ipResponse = await fetch('https://api.ipify.org?format=json')
      const ipData = await ipResponse.json()
      ipAddress = ipData.ip
    } catch (error) {
      console.log('Could not get IP address')
    }
    
    // Create a unique device fingerprint for better session identification
    const deviceFingerprint = `${deviceInfo.userAgent}-${deviceInfo.os}-${deviceInfo.browser}-${deviceInfo.browserVersion}`
    
    // Check if a session already exists for this device with more specific criteria
    const existingSessionQuery = query(
      collection(db, 'deviceSessions'),
      where('userId', '==', authStore.user.uid),
      where('userAgent', '==', deviceInfo.userAgent),
      where('browser', '==', deviceInfo.browser),
      where('browserVersion', '==', deviceInfo.browserVersion)
    )
    
    const existingSessionSnapshot = await getDocs(existingSessionQuery)
    const now = new Date()
    
    if (existingSessionSnapshot.empty) {
      // No existing session found, create a new one
      const sessionId = generateSessionId()
      currentSessionId.value = sessionId
      
      const deviceSession = {
        userId: authStore.user.uid,
        sessionId,
        deviceType: deviceInfo.deviceType,
        deviceName: deviceInfo.deviceName,
        browser: deviceInfo.browser,
        browserVersion: deviceInfo.browserVersion,
        os: deviceInfo.os,
        osVersion: deviceInfo.osVersion,
        userAgent: deviceInfo.userAgent,
        ipAddress,
        location,
        firstLogin: serverTimestamp(),
        lastLogin: serverTimestamp(), // Track actual login time
        lastActive: serverTimestamp(),
        isCurrent: true,
        isActive: true, // Track if session is actually active
        loginCount: 1, // Track number of logins from this device
        deviceFingerprint
      }
      
      // Add to Firestore
      await addDoc(collection(db, 'deviceSessions'), deviceSession)
      console.log('New device session created')
    } else {
      // Existing session found, update it
      const existingSession = existingSessionSnapshot.docs[0]
      const existingData = existingSession.data()
      currentSessionId.value = existingData.sessionId
      
      // Check if this is a new login (more than 30 minutes since last active)
      const lastActiveTime = existingData.lastActive?.toDate() || new Date(0)
      const timeSinceLastActive = now - lastActiveTime
      const isNewLogin = timeSinceLastActive > 30 * 60 * 1000 // 30 minutes
      
      // Update the existing session
      const updateData = {
        lastActive: serverTimestamp(),
        ipAddress,
        location,
        isCurrent: true,
        isActive: true
      }
      
      // If it's a new login, update login time and count
      if (isNewLogin) {
        updateData.lastLogin = serverTimestamp()
        updateData.loginCount = (existingData.loginCount || 0) + 1
        console.log('New login detected for existing device')
      }
      
      await updateDoc(existingSession.ref, updateData)
      
      // Mark all other sessions as not current
      const allSessionsQuery = query(
        collection(db, 'deviceSessions'),
        where('userId', '==', authStore.user.uid)
      )
      
      const allSessionsSnapshot = await getDocs(allSessionsQuery)
      const updatePromises = []
      
      allSessionsSnapshot.forEach((doc) => {
        if (doc.id !== existingSession.id) {
          updatePromises.push(
            updateDoc(doc.ref, {
              isCurrent: false
            })
          )
        }
      })
      
      await Promise.all(updatePromises)
      console.log('Existing device session updated')
    }
    
    // Clean up expired sessions
    await cleanupExpiredSessions()
    
    // Update last active time periodically
    setInterval(updateLastActive, 60000) // Update every minute
    
  } catch (error) {
    console.error('Error registering device session:', error)
  }
}

// Update last active time
const updateLastActive = async () => {
  if (!currentSessionId.value || !authStore.user?.uid) return
  
  try {
    const q = query(
      collection(db, 'deviceSessions'),
      where('userId', '==', authStore.user.uid),
      where('sessionId', '==', currentSessionId.value)
    )
    
    const querySnapshot = await getDocs(q)
    querySnapshot.forEach(async (doc) => {
      await updateDoc(doc.ref, {
        lastActive: serverTimestamp(),
        isActive: true
      })
    })
  } catch (error) {
    console.error('Error updating last active:', error)
  }
}

// Clean up expired sessions (older than 30 days or inactive for more than 7 days)
const cleanupExpiredSessions = async () => {
  if (!authStore.user?.uid) return
  
  try {
    const q = query(
      collection(db, 'deviceSessions'),
      where('userId', '==', authStore.user.uid)
    )
    
    const querySnapshot = await getDocs(q)
    const now = new Date()
    const thirtyDaysAgo = new Date(now.getTime() - (30 * 24 * 60 * 60 * 1000))
    const sevenDaysAgo = new Date(now.getTime() - (7 * 24 * 60 * 60 * 1000))
    
    const deletePromises = []
    
    querySnapshot.forEach((doc) => {
      const data = doc.data()
      const lastActive = data.lastActive?.toDate() || new Date(0)
      const firstLogin = data.firstLogin?.toDate() || new Date(0)
      
      // Delete sessions that are:
      // 1. Older than 30 days from first login, OR
      // 2. Inactive for more than 7 days (and not current session)
      const shouldDelete = 
        firstLogin < thirtyDaysAgo || 
        (lastActive < sevenDaysAgo && !data.isCurrent)
      
      if (shouldDelete) {
        deletePromises.push(deleteDoc(doc.ref))
      }
    })
    
    if (deletePromises.length > 0) {
      await Promise.all(deletePromises)
      console.log(`Cleaned up ${deletePromises.length} expired sessions`)
    }
    
  } catch (error) {
    console.error('Error cleaning up expired sessions:', error)
  }
}

// Clean up duplicate device sessions
const cleanupDuplicateSessions = async () => {
  if (!authStore.user?.uid) return
  
  try {
    const q = query(
      collection(db, 'deviceSessions'),
      where('userId', '==', authStore.user.uid)
    )
    
    const querySnapshot = await getDocs(q)
    const deviceMap = new Map()
    const duplicatesToDelete = []
    
    querySnapshot.forEach((doc) => {
      const data = doc.data()
      const deviceKey = `${data.userAgent}-${data.os}-${data.browser}`
      
      if (deviceMap.has(deviceKey)) {
        // Found a duplicate, keep the most recent one
        const existing = deviceMap.get(deviceKey)
        if (data.lastActive > existing.lastActive) {
          duplicatesToDelete.push(existing.id)
          deviceMap.set(deviceKey, { ...data, id: doc.id })
        } else {
          duplicatesToDelete.push(doc.id)
        }
      } else {
        deviceMap.set(deviceKey, { ...data, id: doc.id })
      }
    })
    
    // Delete duplicate sessions
    if (duplicatesToDelete.length > 0) {
      const deletePromises = duplicatesToDelete.map(id => 
        deleteDoc(doc(db, 'deviceSessions', id))
      )
      await Promise.all(deletePromises)
      console.log(`Cleaned up ${duplicatesToDelete.length} duplicate device sessions`)
    }
    
  } catch (error) {
    console.error('Error cleaning up duplicate sessions:', error)
  }
}

// Fetch user devices
const fetchDevices = async () => {
  if (!authStore.user?.uid) return
  
  isLoadingDevices.value = true
  try {
    // First clean up any duplicates
    await cleanupDuplicateSessions()
    
    const q = query(
      collection(db, 'deviceSessions'),
      where('userId', '==', authStore.user.uid)
    )
    
    const querySnapshot = await getDocs(q)
    const deviceList = []
    
    querySnapshot.forEach((doc) => {
      const data = doc.data()
      const lastActive = data.lastActive?.toDate() || new Date()
      const lastLogin = data.lastLogin?.toDate() || null
      const firstLogin = data.firstLogin?.toDate() || new Date()
      
      deviceList.push({
        id: doc.id,
        ...data,
        isCurrent: data.sessionId === currentSessionId.value,
        // Convert Firestore timestamps to JavaScript dates
        firstLogin,
        lastActive,
        lastLogin,
        // Validate if session is actually active
        isActive: data.isActive !== false // Default to true if not explicitly set to false
      })
    })
    
    // Sort by last active (most recent first)
    devices.value = deviceList.sort((a, b) => b.lastActive - a.lastActive)
    
  } catch (error) {
    console.error('Error fetching devices:', error)
    errorMessage.value = 'Failed to load devices'
    showErrorModal.value = true
  } finally {
    isLoadingDevices.value = false
  }
}

// Update the fetchUserData function with the correct document ID format
const fetchUserData = async () => {
  isLoadingUserData.value = true
  try {
    if (!authStore.user?.uid) {
      return
    }
    
    // Use the correct document ID format: user_[UID]
    // Use only the first 8 characters of the UID
    const documentId = `user_${authStore.user.uid.substring(0, 8)}`
    const userDocRef = doc(db, 'users', documentId)
    
    const userDocSnap = await getDoc(userDocRef)
    
    if (userDocSnap.exists()) {
      userData.value = userDocSnap.data()
    } else {
    }
  } catch (error) {
  } finally {
    isLoadingUserData.value = false
  }
}

// Password validation method
const validatePasswordStrength = () => {
  const password = passwordForm.value.new

  passwordRequirements.value = {
    length: password.length >= 8,
    uppercase: /[A-Z]/.test(password),
    lowercase: /[a-z]/.test(password),
    number: /\d/.test(password),
    special: /[!@#$%^&*(),.?":{}|<>]/.test(password)
  }
}

// Send email verification
const sendVerificationEmail = async () => {
  if (!auth.currentUser) return

  sendingVerification.value = true
  try {
    await sendEmailVerification(auth.currentUser)
    verificationEmailSent.value = true
    statusMessage.value = 'Verification email sent! Please check your inbox.'
    showSuccessModal.value = true
    preventBodyScroll()
  } catch (error) {
    console.error('Error sending verification email:', error)
    errorMessage.value = 'Failed to send verification email. Please try again.'
    showErrorModal.value = true
    preventBodyScroll()
  } finally {
    sendingVerification.value = false
  }
}

const handleImageUpload = (event) => {
  const file = event.target.files[0]
  if (file) {
    if (file.size > 800 * 1024) { // 800K
      errorMessage.value = 'File size exceeds 800K limit'
      showErrorModal.value = true
      preventBodyScroll()
      return
    }
    
    // Store the selected file
    selectedProfilePicture.value = file
    
    // Show preview
    const reader = new FileReader()
    reader.onload = (e) => {
      profileImage.value = e.target.result
      photoChanged.value = true
    }
    reader.readAsDataURL(file)
  }
}

const resetImage = () => {
  profileImage.value = null
  selectedProfilePicture.value = null
  photoChanged.value = false
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

const saveProfilePicture = async () => {
  if (!selectedProfilePicture.value) {
    errorMessage.value = 'No image selected'
    showErrorModal.value = true
    preventBodyScroll()
    return
  }

  isUploadingProfilePicture.value = true

  try {
    const file = selectedProfilePicture.value
    const userId = authStore.user.userId
    
    // Upload to Firebase Storage
    const fileRef = storageRef(storage, `profile-pictures/${userId}/${Date.now()}_${file.name}`)
    const snapshot = await uploadBytes(fileRef, file)
    const downloadURL = await getDownloadURL(snapshot.ref)
    
    // Update user profile in Firestore
    const success = await profileStore.updateUserProfile(userId, {
      photoURL: downloadURL,
      updatedAt: new Date()
    })
    
    if (success) {
      // Clear the selected file and reset states
      selectedProfilePicture.value = null
      photoChanged.value = false
      profileImage.value = null // Clear preview
      
      // Clear file input
      if (fileInput.value) {
        fileInput.value.value = ''
      }
      
      // Show success message
      statusMessage.value = 'Profile picture updated successfully!'
      showSuccessModal.value = true
      preventBodyScroll()
    } else {
      throw new Error('Failed to update profile')
    }
    
  } catch (error) {
    console.error('Error saving profile picture:', error)
    errorMessage.value = 'Failed to save profile picture. Please try again.'
    showErrorModal.value = true
    preventBodyScroll()
  } finally {
    isUploadingProfilePicture.value = false
  }
}

const updatePassword = async () => {
  if (!canChangePassword.value) {
    errorMessage.value = 'Please ensure your password meets all requirements and passwords match'
    showErrorModal.value = true
    return
  }

  isUpdating.value = true

  try {
    const user = auth.currentUser
    if (!user) {
      throw new Error('No authenticated user found')
    }
    
    // Check if email is verified (from either source)
    await reload(user)
    if (!isEmailVerified.value) {
      errorMessage.value = 'Please verify your email before changing your password.'
      showErrorModal.value = true
      return
    }
    
    // Reauthenticate user with current password
    const credential = EmailAuthProvider.credential(
      user.email,
      passwordForm.value.current
    )
    
    await reauthenticateWithCredential(user, credential)
    
    // Update password
    await firebaseUpdatePassword(user, passwordForm.value.new)
    
    // Clear form
    passwordForm.value = {
      current: '',
      new: '',
      confirm: ''
    }
    
    // Show success message
    statusMessage.value = 'Password updated successfully!'
    showSuccessModal.value = true
    preventBodyScroll()
    
  } catch (error) {
    console.error('Error changing password:', error)
    
    if (error.code === 'auth/wrong-password') {
      errorMessage.value = 'Current password is incorrect.'
    } else if (error.code === 'auth/weak-password') {
      errorMessage.value = 'New password is too weak.'
    } else if (error.code === 'auth/requires-recent-login') {
      errorMessage.value = 'Please log out and log back in before changing your password.'
    } else {
      errorMessage.value = error.message || 'Failed to change password. Please try again.'
    }
    
    showErrorModal.value = true
    preventBodyScroll()
  } finally {
    isUpdating.value = false
  }
}

// Device management functions
const confirmSignOutDevice = (device) => {
  deviceToSignOut.value = device
  showSignOutDeviceConfirmation.value = true
  activeDeviceMenu.value = null
  preventBodyScroll()
}

// Sign out from a specific device
const signOutDevice = async (deviceId) => {
  signingOutDevices.value.push(deviceId)
  showSignOutDeviceConfirmation.value = false
  restoreBodyScroll()
  
  try {
    // Delete the device session from Firestore
    await deleteDoc(doc(db, 'deviceSessions', deviceId))
    
    // Remove from local list
    devices.value = devices.value.filter(device => device.id !== deviceId)
    
    statusMessage.value = 'Device signed out successfully. The user will need to sign in again on that device.'
    showSuccessModal.value = true
    
  } catch (error) {
    console.error('Error signing out device:', error)
    errorMessage.value = 'Failed to sign out device'
    showErrorModal.value = true
  } finally {
    signingOutDevices.value = signingOutDevices.value.filter(id => id !== deviceId)
    deviceToSignOut.value = null
  }
}

// Sign out from all devices
const signOutFromAllDevices = async () => {
  isSigningOutAll.value = true
  showSignOutAllConfirmation.value = false
  restoreBodyScroll()
  
  try {
    const q = query(
      collection(db, 'deviceSessions'),
      where('userId', '==', authStore.user.uid)
    )
    
    const querySnapshot = await getDocs(q)
    const deletePromises = []
    
    querySnapshot.forEach((doc) => {
      // Don't delete current session
      if (doc.data().sessionId !== currentSessionId.value) {
        deletePromises.push(deleteDoc(doc.ref))
      }
    })
    
    await Promise.all(deletePromises)
    
    // Refresh devices list
    await fetchDevices()
    
    statusMessage.value = 'Successfully signed out from all other devices. Users will need to sign in again on those devices.'
    showSuccessModal.value = true
    
  } catch (error) {
    console.error('Error signing out from all devices:', error)
    errorMessage.value = 'Failed to sign out from all devices'
    showErrorModal.value = true
  } finally {
    isSigningOutAll.value = false
  }
}

// Toggle device menu
const toggleDeviceMenu = (deviceId) => {
  activeDeviceMenu.value = activeDeviceMenu.value === deviceId ? null : deviceId
}

// Toggle show all devices
const toggleShowAllDevices = () => {
  showAllDevices.value = !showAllDevices.value
}


// Modal utility functions
const preventBodyScroll = () => {
  document.body.style.overflow = 'hidden'
}

const restoreBodyScroll = () => {
  document.body.style.overflow = ''
}

// Prevent modal from closing when clicking outside
const preventModalClose = (event) => {
  event.stopPropagation()
}

// Help modal functions
const openHelpModal = () => {
  showHelpModal.value = true
  preventBodyScroll()
}

const closeHelpModal = () => {
  showHelpModal.value = false
  restoreBodyScroll()
}

// View device details
const viewDeviceDetails = (device) => {
  selectedDevice.value = device
  showDeviceDetails.value = true
  activeDeviceMenu.value = null
  preventBodyScroll()
}

// Get device icon based on type
const getDeviceIcon = (deviceType) => {
  switch (deviceType) {
    case 'mobile':
      return SmartphoneIcon
    case 'tablet':
      return TabletIcon
    case 'desktop':
    default:
      return LaptopIcon
  }
}

// Format last active time with better accuracy
const formatLastActive = (date) => {
  if (!date) return 'Unknown'
  
  const now = new Date()
  const diff = now - date
  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(diff / 3600000)
  const days = Math.floor(diff / 86400000)
  const weeks = Math.floor(days / 7)
  const months = Math.floor(days / 30)
  
  if (minutes < 1) return 'Just now'
  if (minutes < 60) return `${minutes} minute${minutes !== 1 ? 's' : ''} ago`
  if (hours < 24) return `${hours} hour${hours !== 1 ? 's' : ''} ago`
  if (days < 7) return `${days} day${days !== 1 ? 's' : ''} ago`
  if (weeks < 4) return `${weeks} week${weeks !== 1 ? 's' : ''} ago`
  if (months < 12) return `${months} month${months !== 1 ? 's' : ''} ago`
  
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

// Format date with timezone awareness
const formatDate = (date) => {
  if (!date) return 'Unknown'
  
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    timeZoneName: 'short'
  })
}

// Format login time with more context
const formatLoginTime = (date) => {
  if (!date) return 'Unknown'
  
  const now = new Date()
  const diff = now - date
  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(diff / 3600000)
  const days = Math.floor(diff / 86400000)
  
  if (minutes < 1) return 'Just logged in'
  if (minutes < 60) return `Logged in ${minutes} minute${minutes !== 1 ? 's' : ''} ago`
  if (hours < 24) return `Logged in ${hours} hour${hours !== 1 ? 's' : ''} ago`
  if (days < 7) return `Logged in ${days} day${days !== 1 ? 's' : ''} ago`
  
  return `Logged in on ${date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })}`
}

// Close device menu when clicking outside
const handleClickOutside = (event) => {
  if (!event.target.closest('.relative')) {
    activeDeviceMenu.value = null
  }
}

const autoSaveNotification = async () => {
  notificationSaved.value = false
  try {
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 500))
    notificationSaved.value = true
    
    // Hide the saved indicator after 3 seconds
    setTimeout(() => {
      notificationSaved.value = false
    }, 3000)
  } catch (error) {
    // Handle error
    console.error('Failed to save notification setting', error)
  }
}

const saveNotificationSettings = async () => {
  isSavingNotifications.value = true
  try {
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000))
    notificationSaved.value = true
    
    // Hide the saved indicator after 3 seconds
    setTimeout(() => {
      notificationSaved.value = false
    }, 3000)
  } catch (error) {
    errorMessage.value = 'Failed to save notification settings'
    showErrorModal.value = true
    preventBodyScroll()
  } finally {
    isSavingNotifications.value = false
  }
}

const deleteAccount = async () => {
  if (deleteConfirmText.value !== 'delete') {
    return
  }

  try {
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000))
    statusMessage.value = 'Your account has been deleted successfully'
    showSuccessModal.value = true
    preventBodyScroll()
    // Here you would typically redirect to a logout page or home page
  } catch (error) {
    errorMessage.value = 'Failed to delete account'
    showErrorModal.value = true
    preventBodyScroll()
  } finally {
    showDeleteConfirmation.value = false
    deleteConfirmText.value = ''
    restoreBodyScroll()
  }
}

// Update the onMounted function
onMounted(async () => {
  // Wait a bit for auth store to be fully loaded if needed
  if (!authStore.user?.uid) {
    // Wait up to 3 seconds for auth to load
    let attempts = 0
    while (!authStore.user?.uid && attempts < 30) {
      await new Promise(resolve => setTimeout(resolve, 100))
      attempts++
    }
  }
  
  if (authStore.user?.uid) {
    await fetchUserData()
    await registerDeviceSession()
    await fetchDevices()
    // Fetch user profile for profile picture display
    await profileStore.fetchUserProfile(authStore.user.uid)
  } else {
  }
  
  // Add click outside listener
  document.addEventListener('click', handleClickOutside)
})

// Watch for profile changes to update the displayed profile picture
watch(() => profileStore.profile, (newProfile) => {
  if (newProfile?.photoURL && !photoChanged.value) {
    // Only update if user hasn't selected a new picture
    profileImage.value = null
  }
}, { deep: true })

onUnmounted(() => {
  // Clean up event listener
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
input[type="password"]::-ms-reveal,
input[type="password"]::-ms-clear {
  display: none;
}

.animate-fade-out {
  animation: fadeOut 3s forwards;
}

@keyframes fadeOut {
  0% { opacity: 1; }
  70% { opacity: 1; }
  100% { opacity: 0; }
}
</style>