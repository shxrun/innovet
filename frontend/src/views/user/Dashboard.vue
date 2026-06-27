<!-- views/user/Dashboard.vue -->
<template>
  <div class="min-h-screen flex flex-col bg-gray-50 -mt-4 md:mt-0">
    <!-- Main content area with adjusted padding for mobile -->
    <div class="flex flex-col flex-1 px-2 sm:px-4 md:px-6 pb-20 pt-14 md:pt-0 md:pb-4">
      <div class="grid grid-cols-1 lg:grid-cols-4 gap-3 md:gap-4 lg:gap-6">
        <!-- Left Column (3/4 width on large screens) -->
        <div class="lg:col-span-3 flex flex-col gap-3 md:gap-4">
          <!-- Welcome Banner - Enhanced with stats -->
          <div class="bg-gradient-to-r from-blue-600 to-blue-800 rounded-2xl p-4 sm:p-4 md:p-6 flex items-center justify-between overflow-hidden relative h-[160px] sm:h-[140px] md:h-[180px] flex-shrink-0">
            <div class="text-white z-10 max-w-[55%] sm:max-w-[60%] md:max-w-[65%]">
              <h1 class="text-base sm:text-lg md:text-xl lg:text-2xl font-bold mb-1 sm:mb-2 md:mb-3">Welcome to InnoVET!</h1>
              <p class="text-[10px] sm:text-xs md:text-sm lg:text-base text-blue-100 mb-2 sm:mb-3 md:mb-4 leading-tight">Track your pet's health, manage appointments, and get reminders for vaccinations.</p>
              <div class="flex flex-row gap-2 sm:gap-2 md:gap-3">
                <router-link 
                  to="/user/userappointments" 
                  class="bg-white text-blue-600 px-4 py-2 rounded-full text-[10px] sm:text-xs md:text-sm font-medium hover:bg-blue-50 transition-colors inline-flex items-center justify-center whitespace-nowrap"
                >
                  <span class="hidden sm:inline">Book Appointment</span>
                  <span class="sm:hidden">Book</span>
                </router-link>
                <router-link 
                  to="/user/profile?tab=pet-info" 
                  class="bg-blue-500 text-white px-4 py-2 rounded-full text-[10px] sm:text-xs md:text-sm font-medium hover:bg-blue-400 transition-colors inline-flex items-center justify-center whitespace-nowrap"
                >
                  <span class="hidden sm:inline">Manage Pets</span>
                  <span class="sm:hidden">Pets</span>
                </router-link>
              </div>
            </div>
            <div class="absolute right-0 top-0 h-full w-[45%] sm:w-[40%] md:w-1/2 flex items-center justify-end">
              <img src="/src/assets/media/images/common/banner.png" 
                  alt="Veterinarian with dog illustration" 
                  class="h-full object-contain" />
            </div>
          </div>

          <!-- Quick Stats Row -->
          <div class="grid grid-cols-3 gap-2 sm:grid-cols-2 lg:grid-cols-3 sm:gap-3 md:gap-4">
            <!-- Loading state for stats -->
            <div v-if="isPetsLoading || isLoading" class="bg-white rounded-2xl p-2 sm:p-3 md:p-4 shadow-sm border border-gray-100 h-[80px] sm:h-auto">
              <div class="flex flex-col items-center justify-center h-full text-center sm:flex-row sm:items-center sm:text-left">
                <div class="w-6 h-6 sm:w-8 sm:h-8 md:w-10 md:h-10 lg:w-12 lg:h-12 bg-gray-200 rounded-lg sm:rounded-xl flex items-center justify-center mb-1 sm:mb-0 sm:mr-2 md:mr-3 lg:mr-4 flex-shrink-0 animate-pulse"></div>
                <div class="flex-1 flex flex-col justify-center min-h-[32px] sm:min-h-0">
                  <div class="w-[80%] h-2 sm:h-3 bg-gray-200 rounded mb-1 animate-pulse"></div>
                  <div class="w-[60%] h-4 sm:h-6 bg-gray-200 rounded animate-pulse"></div>
                </div>
              </div>
            </div>
            <div v-if="isPetsLoading || isLoading" class="bg-white rounded-2xl p-2 sm:p-3 md:p-4 shadow-sm border border-gray-100 h-[80px] sm:h-auto">
              <div class="flex flex-col items-center justify-center h-full text-center sm:flex-row sm:items-center sm:text-left">
                <div class="w-6 h-6 sm:w-8 sm:h-8 md:w-10 md:h-10 lg:w-12 lg:h-12 bg-gray-200 rounded-lg sm:rounded-xl flex items-center justify-center mb-1 sm:mb-0 sm:mr-2 md:mr-3 lg:mr-4 flex-shrink-0 animate-pulse"></div>
                <div class="flex-1 flex flex-col justify-center min-h-[32px] sm:min-h-0">
                  <div class="w-[80%] h-2 sm:h-3 bg-gray-200 rounded mb-1 animate-pulse"></div>
                  <div class="w-[60%] h-4 sm:h-6 bg-gray-200 rounded animate-pulse"></div>
                </div>
              </div>
            </div>
            <div v-if="isPetsLoading || isLoading" class="bg-white rounded-2xl p-2 sm:p-3 md:p-4 shadow-sm border border-gray-100 h-[80px] sm:h-auto">
              <div class="flex flex-col items-center justify-center h-full text-center sm:flex-row sm:items-center sm:text-left">
                <div class="w-6 h-6 sm:w-8 sm:h-8 md:w-10 md:h-10 lg:w-12 lg:h-12 bg-gray-200 rounded-lg sm:rounded-xl flex items-center justify-center mb-1 sm:mb-0 sm:mr-2 md:mr-3 lg:mr-4 flex-shrink-0 animate-pulse"></div>
                <div class="flex-1 flex flex-col justify-center min-h-[32px] sm:min-h-0">
                  <div class="w-[80%] h-2 sm:h-3 bg-gray-200 rounded mb-1 animate-pulse"></div>
                  <div class="w-[60%] h-4 sm:h-6 bg-gray-200 rounded animate-pulse"></div>
                </div>
              </div>
            </div>
            
            <!-- Actual stats when loaded -->
            <div v-if="!isPetsLoading && !isLoading" class="bg-white rounded-2xl p-2 sm:p-3 md:p-4 shadow-sm border border-blue-50 h-[80px] sm:h-auto">
              <div class="flex flex-col items-center justify-center h-full text-center sm:flex-row sm:items-center sm:text-left">
                <div class="w-6 h-6 sm:w-8 sm:h-8 md:w-10 md:h-10 lg:w-12 lg:h-12 bg-blue-100 rounded-lg sm:rounded-xl flex items-center justify-center mb-1 sm:mb-0 sm:mr-2 md:mr-3 lg:mr-4 flex-shrink-0">
                  <CalendarIcon class="w-3 h-3 sm:w-4 sm:h-4 md:w-5 md:h-5 lg:w-6 lg:h-6 text-blue-600" />
                </div>
                <div class="flex-1 flex flex-col justify-center min-h-[32px] sm:min-h-0">
                  <p class="text-[8px] sm:text-[10px] md:text-xs lg:text-sm text-gray-600 leading-tight h-[12px] sm:h-auto flex items-center justify-center sm:justify-start">Today's Appointments</p>
                  <p class="text-sm sm:text-lg md:text-xl lg:text-2xl font-bold text-gray-900 h-[16px] sm:h-auto flex items-center justify-center sm:justify-start">{{ todayAppointmentsCount }}</p>
                </div>
              </div>
            </div>
            
            <div v-if="!isPetsLoading && !isLoading" class="bg-white rounded-2xl p-2 sm:p-3 md:p-4 shadow-sm border border-green-50 h-[80px] sm:h-auto">
              <div class="flex flex-col items-center justify-center h-full text-center sm:flex-row sm:items-center sm:text-left">
                <div class="w-6 h-6 sm:w-8 sm:h-8 md:w-10 md:h-10 lg:w-12 lg:h-12 bg-green-100 rounded-lg sm:rounded-xl flex items-center justify-center mb-1 sm:mb-0 sm:mr-2 md:mr-3 lg:mr-4 flex-shrink-0">
                  <HeartIcon class="w-3 h-3 sm:w-4 sm:h-4 md:w-5 md:h-5 lg:w-6 lg:h-6 text-green-600" />
                </div>
                <div class="flex-1 flex flex-col justify-center min-h-[32px] sm:min-h-0">
                  <p class="text-[8px] sm:text-[10px] md:text-xs lg:text-sm text-gray-600 leading-tight h-[12px] sm:h-auto flex items-center justify-center sm:justify-start">Active Pets</p>
                  <p class="text-sm sm:text-lg md:text-xl lg:text-2xl font-bold text-gray-900 h-[16px] sm:h-auto flex items-center justify-center sm:justify-start">{{ pets.length }}</p>
                </div>
              </div>
            </div>
            
            <div v-if="!isPetsLoading && !isLoading" class="bg-white rounded-2xl p-2 sm:p-3 md:p-4 shadow-sm border border-purple-50 h-[80px] sm:h-auto">
              <div class="flex flex-col items-center justify-center h-full text-center sm:flex-row sm:items-center sm:text-left">
                <div class="w-6 h-6 sm:w-8 sm:h-8 md:w-10 md:h-10 lg:w-12 lg:h-12 bg-purple-100 rounded-lg sm:rounded-xl flex items-center justify-center mb-1 sm:mb-0 sm:mr-2 md:mr-3 lg:mr-4 flex-shrink-0">
                  <BookOpenIcon class="w-3 h-3 sm:w-4 sm:h-4 md:w-5 md:h-5 lg:w-6 lg:h-6 text-purple-600" />
                </div>
                <div class="flex-1 flex flex-col justify-center min-h-[32px] sm:min-h-0">
                  <p class="text-[8px] sm:text-[10px] md:text-xs lg:text-sm text-gray-600 leading-tight h-[12px] sm:h-auto flex items-center justify-center sm:justify-start">Resources Available</p>
                  <p class="text-sm sm:text-lg md:text-xl lg:text-2xl font-bold text-gray-900 h-[16px] sm:h-auto flex items-center justify-center sm:justify-start">{{ displayedResources.length }}</p>
                </div>
              </div>
            </div>
          </div>

          <!-- My Pets - Enhanced with better layout -->
          <div class="bg-white rounded-2xl p-3 sm:p-4 md:p-6 shadow-sm border border-blue-50 min-h-[200px] sm:min-h-0">
            <div class="flex flex-row justify-between items-start mb-3 sm:mb-4 md:mb-6 gap-2">
              <div class="min-w-0 flex-1">
                <h2 class="text-base sm:text-lg md:text-xl font-semibold text-gray-800">My Pets</h2>
                <p class="text-xs sm:text-sm text-gray-600 mt-1">Manage your pets and view their health status</p>
              </div>
              <router-link 
                to="/user/profile?tab=pet-info&addPet=true" 
                class="bg-blue-500 text-white px-4 py-2 sm:px-3 sm:py-1.5 md:px-4 md:py-2 rounded-full text-[10px] sm:text-xs md:text-sm font-medium hover:bg-blue-600 transition-colors flex items-center justify-center w-auto flex-shrink-0"
              >
                <PlusCircle class="w-3 h-3 sm:w-4 sm:h-4 mr-1 sm:mr-2" />
                Add Pet 
              </router-link>
            </div>
            
            <!-- Loading state for pets with skeleton -->
            <div v-if="isPetsLoading" class="grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-3 gap-2 sm:gap-3 md:gap-4">
              <div v-for="i in 3" :key="i" class="bg-gradient-to-br from-gray-50 to-white border border-gray-100 rounded-xl overflow-hidden">
                <div class="aspect-[3/2] bg-gray-200 animate-pulse"></div>
                <div class="p-2">
                  <div class="w-[90%] h-3 rounded bg-gray-200 mb-1 animate-pulse"></div>
                  <div class="w-[60%] h-2 rounded bg-gray-200 mb-1.5 animate-pulse"></div>
                  <div class="flex flex-row gap-1.5">
                    <div class="flex-1 h-6 rounded-full bg-gray-200 animate-pulse"></div>
                    <div class="flex-1 h-6 rounded-full bg-gray-200 animate-pulse"></div>
                  </div>
                </div>
              </div>
            </div>
            <!-- Error state -->
            <div v-else-if="petsError" class="text-center text-red-500 py-8">{{ petsError }}</div>
            <!-- Empty state - only show when not loading and no pets -->
            <div v-else-if="!isPetsLoading && pets.length === 0" class="text-center py-12">
              <div class="w-20 h-20 bg-blue-50 rounded-full flex items-center justify-center mx-auto mb-4">
                <HeartIcon class="w-10 h-10 text-blue-400" />
              </div>
              <h3 class="text-lg font-medium text-gray-900 mb-2">No pets added yet</h3>
              <p class="text-gray-500 mb-6">Add your first pet to get started with ProVET services.</p>
              <router-link 
                to="/user/profile?tab=pet-info&addPet=true" 
                class="bg-blue-600 text-white px-2 py-1 sm:px-3 sm:py-1.5 md:px-4 md:py-2 rounded-full text-[10px] sm:text-xs md:text-sm font-medium hover:bg-blue-700 transition-colors inline-flex items-center"
              >
                <PlusIcon class="w-3 h-3 sm:w-4 sm:h-4 mr-1 sm:mr-2" />
                Add Your First Pet
              </router-link>
            </div>
            <div v-else>
              <div class="grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-3 gap-2 sm:gap-3 md:gap-4">
                <div v-for="(pet, index) in pets.slice(0, 3)" :key="index" 
                    class="bg-gradient-to-br from-gray-50 to-white border border-gray-100 rounded-xl overflow-hidden hover:shadow-lg transition-all duration-300 hover:scale-[1.02] cursor-pointer">
                  <div class="aspect-[3/2] bg-gradient-to-r from-blue-100 to-indigo-100 flex-shrink-0 relative">
                    <img :src="pet.image || defaultPetPhotoURL" :alt="pet.name" class="w-full h-full object-cover" />
                    <div class="absolute top-1 left-1">
                      <span class="px-1 py-0.5 rounded-full text-[10px] font-medium bg-white/90 backdrop-blur-sm text-gray-700">
                        {{ pet.age }}
                      </span>
                    </div>
                  </div>
                  <div class="p-2">
                    <h3 class="text-xs font-medium text-gray-800 mb-0.5">{{ pet.name }}</h3>
                    <div class="flex items-center text-[10px] text-gray-500 mb-1.5">
                      <span>{{ pet.breed }} • {{ pet.species }}</span>
                    </div>
                    
                    <div class="flex flex-row gap-1.5">
                      <router-link 
                        :to="`/user/profile?tab=pet-info&petId=${pet.id}`"
                        class="flex-1 bg-blue-600 text-white px-2 py-1.5 rounded-full text-xs font-medium hover:bg-blue-700 transition-colors text-center"
                      >
                        <span class="hidden sm:inline">View Details</span>
                        <span class="sm:hidden">View</span>
                      </router-link>
                      <router-link 
                        :to="`/user/userappointments?petId=${pet.id}`"
                        class="flex-1 bg-white text-blue-600 px-2 py-1.5 rounded-full text-xs font-medium hover:bg-blue-50 transition-colors border border-blue-200 text-center"
                      >
                        <span class="hidden sm:inline">Book Appointment</span>
                        <span class="sm:hidden">Book</span>
                      </router-link>
                    </div>
                  </div>
                </div>
                
                <!-- View All card inline with pet cards on small screens -->
                <div v-if="pets.length > 3" class="sm:hidden">
                  <router-link 
                    to="/user/profile?tab=pet-info" 
                    class="bg-gradient-to-br from-blue-50 to-blue-100 border border-blue-200 rounded-xl overflow-hidden hover:shadow-lg transition-all duration-300 hover:scale-[1.02] cursor-pointer flex flex-col items-center justify-center p-4 min-h-[120px] h-full"
                  >
                    <div class="flex flex-col items-center justify-center text-center">
                      <div class="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center mb-2">
                        <ChevronRightIcon class="w-4 h-4 text-white" />
                      </div>
                      <h3 class="text-xs font-medium text-blue-700 mb-1">View All</h3>
                      <p class="text-[10px] text-blue-600">{{ pets.length }} Pets</p>
                    </div>
                  </router-link>
                </div>
              </div>
              
              <!-- Link style for larger screens -->
              <div v-if="pets.length > 3" class="hidden sm:flex justify-center mt-4">
                <router-link 
                  to="/user/profile?tab=pet-info" 
                  class="text-blue-600 text-[10px] sm:text-xs md:text-sm font-medium hover:text-blue-700 text-center flex-shrink-0"
                >
                  View All
                </router-link>
              </div>
            </div>
          </div>

          <!-- Educational Resources - Enhanced -->
          <div class="bg-white rounded-2xl p-3 sm:p-4 md:p-6 shadow-sm border border-blue-50 min-h-[200px] sm:min-h-0">
            <div class="flex flex-col sm:flex-row sm:justify-between sm:items-start mb-3 sm:mb-4 md:mb-6 gap-2 sm:gap-0">
              <div class="min-w-0 flex-1">
                <h2 class="text-base sm:text-lg md:text-xl font-semibold text-gray-800">Educational Resources</h2>
                <p class="text-xs sm:text-sm text-gray-600 mt-1">Learn more about pet care and health</p>
              </div>
              <!-- Tab style for larger screens -->
              <div class="hidden sm:block">
                <router-link to="/user/educational-resources" class="px-2 py-1 text-xs sm:px-3 sm:py-2 sm:text-sm font-medium rounded-full transition-colors min-w-[70px] sm:min-w-[80px] whitespace-nowrap bg-[#EBF5FF] text-[#0066FF] hover:bg-[#D1E7FF] flex-shrink-0">View All</router-link>
              </div>
            </div>
            
            <!-- Loading state with skeleton -->
            <div v-if="isLoading" class="grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-3 gap-2 sm:gap-3 md:gap-4">
              <div v-for="i in 3" :key="i" class="bg-gradient-to-br from-gray-50 to-white border border-gray-100 rounded-xl overflow-hidden">
                <div class="aspect-[3/2] bg-gray-200 animate-pulse"></div>
                <div class="p-2">
                  <div class="w-[90%] h-3 rounded bg-gray-200 mb-1 animate-pulse"></div>
                  <div class="w-[60%] h-2 rounded bg-gray-200 animate-pulse"></div>
                </div>
              </div>
            </div>
            
            <!-- Resources grid -->
            <div v-else class="grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-3 gap-2 sm:gap-3 md:gap-4">
              <div v-for="resource in displayedResources.slice(0, 3)" :key="resource.id" 
                  class="bg-gradient-to-br from-gray-50 to-white border border-gray-100 rounded-xl overflow-hidden hover:shadow-lg transition-all duration-300 hover:scale-[1.02] cursor-pointer"
                  @click="openResourceModal(resource)">
                <div class="aspect-[3/2] bg-gradient-to-r from-blue-100 to-indigo-100 flex-shrink-0 relative">
                  <img 
                    v-if="resource.coverPhoto" 
                    :src="resource.coverPhoto" 
                    :alt="resource.name" 
                    class="w-full h-full object-cover" 
                  />
                  <div v-else class="w-full h-full flex items-center justify-center">
                    <FileIcon class="w-5 h-5 sm:w-6 sm:h-6 text-blue-400" />
                  </div>
                  <div class="absolute top-1 left-1">
                    <span :class="`px-1 py-0.5 rounded-full text-[10px] font-medium bg-white/90 backdrop-blur-sm ${getTagColor(resource.type)}`">
                      {{ resource.type }}
                    </span>
                  </div>
                </div>
                <div class="p-2">
                  <h3 class="text-xs font-medium text-gray-800 mb-0.5 line-clamp-2">{{ resource.name }}</h3>
                  <div class="flex items-center text-[10px] text-gray-500">
                    <ClockIcon class="w-3 h-3 mr-1" />
                    <span>{{ getReadTime(resource.description) }} min read</span>
                  </div>
                </div>
              </div>
              
              <!-- View All card inline with resources on small screens -->
              <div class="sm:hidden">
                <router-link to="/user/educational-resources" class="bg-gradient-to-br from-blue-50 to-blue-100 border border-blue-200 rounded-xl overflow-hidden hover:shadow-lg transition-all duration-300 hover:scale-[1.02] cursor-pointer flex flex-col items-center justify-center p-4 min-h-[120px] h-full">
                  <div class="flex flex-col items-center justify-center text-center">
                    <div class="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center mb-2">
                      <ChevronRightIcon class="w-4 h-4 text-white" />
                    </div>
                    <h3 class="text-xs font-medium text-blue-700 mb-1">View All</h3>
                    <p class="text-[10px] text-blue-600">Resources</p>
                  </div>
                </router-link>
              </div>
              
              <!-- Empty state if no resources -->
              <div v-if="displayedResources.length === 0" class="col-span-full text-center py-8">
                <BookOpenIcon class="w-12 h-12 text-gray-300 mx-auto mb-3" />
                <p class="text-gray-500">No resources available at the moment.</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Right Column (1/4 width on large screens) -->
        <div class="flex flex-col gap-3 md:gap-4 lg:gap-6">
          <!-- Calendar Component -->
          <div class="bg-white rounded-2xl shadow-sm border border-blue-50 overflow-hidden">
            <CalendarComponent />
          </div>

          <!-- Queue Position Component -->
          <QueuePosition />

          <!-- Quick Actions -->
          <div class="bg-white rounded-2xl p-4 sm:p-5 md:p-6 shadow-sm border border-blue-50 min-h-[250px] sm:min-h-[220px] md:min-h-0">
            <h3 class="text-lg sm:text-lg md:text-xl font-semibold text-gray-800 mb-4 sm:mb-4 md:mb-5 truncate">Quick Actions</h3>
            <div class="space-y-3 sm:space-y-3 md:space-y-4">
              <router-link 
                to="/user/userappointments" 
                class="flex items-center p-3 sm:p-3 md:p-4 bg-blue-50 hover:bg-blue-100 rounded-lg transition-colors group"
              >
                <div class="w-8 h-8 sm:w-8 sm:h-8 md:w-10 md:h-10 bg-blue-100 rounded-lg flex items-center justify-center mr-3 sm:mr-3 md:mr-4 group-hover:bg-blue-200 transition-colors flex-shrink-0">
                  <CalendarIcon class="w-5 h-5 sm:w-4 sm:h-4 md:w-5 md:h-5 text-blue-600" />
                </div>
                <div class="min-w-0 flex-1">
                  <div class="text-sm sm:text-sm md:text-base font-medium text-gray-800 truncate">Book Appointment</div>
                  <div class="text-xs sm:text-xs md:text-sm text-gray-600 truncate">Schedule a visit</div>
                </div>
              </router-link>
              
              <router-link 
                to="/user/profile?tab=pet-info" 
                class="flex items-center p-3 sm:p-3 md:p-4 bg-green-50 hover:bg-green-100 rounded-lg transition-colors group"
              >
                <div class="w-8 h-8 sm:w-8 sm:h-8 md:w-10 md:h-10 bg-green-100 rounded-lg flex items-center justify-center mr-3 sm:mr-3 md:mr-4 group-hover:bg-green-200 transition-colors flex-shrink-0">
                  <HeartIcon class="w-5 h-5 sm:w-4 sm:h-4 md:w-5 md:h-5 text-green-600" />
                </div>
                <div class="min-w-0 flex-1">
                  <div class="text-sm sm:text-sm md:text-base font-medium text-gray-800 truncate">Manage Pets</div>
                  <div class="text-xs sm:text-xs md:text-sm text-gray-600 truncate">Update pet info</div>
                </div>
              </router-link>
              
              <router-link 
                to="/user/educational-resources" 
                class="flex items-center p-3 sm:p-3 md:p-4 bg-purple-50 hover:bg-purple-100 rounded-lg transition-colors group"
              >
                <div class="w-8 h-8 sm:w-8 sm:h-8 md:w-10 md:h-10 bg-purple-100 rounded-lg flex items-center justify-center mr-3 sm:mr-3 md:mr-4 group-hover:bg-purple-200 transition-colors flex-shrink-0">
                  <BookOpenIcon class="w-5 h-5 sm:w-4 sm:h-4 md:w-5 md:h-5 text-purple-600" />
                </div>
                <div class="min-w-0 flex-1">
                  <div class="text-sm sm:text-sm md:text-base font-medium text-gray-800 truncate">Learn More</div>
                  <div class="text-xs sm:text-xs md:text-sm text-gray-600 truncate">Educational content</div>
                </div>
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Resource Modal -->
    <div v-if="isResourceModalOpen && selectedResource" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-2 sm:p-4" @click.self="closeResourceModal">
      <div class="bg-white rounded-2xl max-w-3xl w-full max-h-[95vh] sm:max-h-[90vh] overflow-hidden shadow-2xl flex flex-col" role="dialog" aria-labelledby="resource-modal-title">
        <div class="sticky top-0 bg-white p-3 sm:p-4 border-b flex justify-between items-center z-10 flex-shrink-0">
          <div class="flex flex-col sm:flex-row sm:items-center gap-1 sm:gap-0">
            <span :class="`px-2 py-0.5 rounded-full text-xs ${getTagColor(selectedResource.type)}`">
              {{ selectedResource.type }}
            </span>
            <span class="text-xs text-gray-500 sm:ml-2 flex items-center">
              <ClockIcon class="w-3 h-3 mr-1" />
              {{ getReadTime(selectedResource.description) }} min read
            </span>
          </div>
          <button @click="closeResourceModal" class="p-1 rounded-full hover:bg-gray-100">
            <XIcon class="w-5 h-5 text-gray-500" />
          </button>
        </div>
        
        <div class="p-4 sm:p-6 overflow-y-auto flex-1">
          <div class="aspect-video bg-gray-100 rounded-xl overflow-hidden mb-4 sm:mb-6">
            <img 
              v-if="selectedResource.coverPhoto" 
              :src="selectedResource.coverPhoto" 
              :alt="selectedResource.name" 
              class="w-full h-full object-cover" 
            />
            <div v-else class="w-full h-full flex items-center justify-center bg-blue-100">
              <FileIcon class="w-12 h-12 sm:w-16 sm:h-16 text-blue-500" />
            </div>
          </div>
          
          <h1 class="text-xl sm:text-2xl font-bold mb-3 sm:mb-4">{{ selectedResource.name }}</h1>
          
          <div class="prose max-w-none">
            <p v-if="selectedResource.description" v-html="formatDescription(selectedResource.description)"></p>
            <p v-else class="text-gray-500 italic">No description available</p>
          </div>
          
          <div class="mt-6 sm:mt-8 flex flex-col sm:flex-row sm:justify-between sm:items-center pt-4 border-t gap-3 sm:gap-0">
            <div class="flex items-center">
              <div class="w-8 h-8 sm:w-10 sm:h-10 rounded-full bg-blue-100 flex items-center justify-center">
                <UserIcon class="w-4 h-4 sm:w-5 sm:h-5 text-blue-600" />
              </div>
              <div class="ml-2 sm:ml-3">
                <p class="text-xs sm:text-sm font-medium">{{ getCategoryName(selectedResource.categoryId) }}</p>
                <p class="text-xs text-gray-500">{{ formatDate(selectedResource.createdAt) }}</p>
              </div>
            </div>
            <div class="flex space-x-2">
              <button class="p-1.5 sm:p-2 rounded-full bg-gray-100 hover:bg-gray-200">
                <BookmarkIcon class="w-3.5 h-3.5 sm:w-4 sm:h-4 text-gray-600" />
              </button>
              <button class="p-1.5 sm:p-2 rounded-full bg-gray-100 hover:bg-gray-200">
                <ShareIcon class="w-3.5 h-3.5 sm:w-4 sm:h-4 text-gray-600" />
              </button>
            </div>
          </div>
          
          <div class="mt-6 sm:mt-8" v-if="relatedResources.length > 0">
            <h3 class="text-base sm:text-lg font-medium mb-3 sm:mb-4">Related Resources</h3>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-4">
              <div 
                v-for="resource in relatedResources" 
                :key="resource.id" 
                class="flex border rounded-lg overflow-hidden hover:shadow-sm transition-shadow cursor-pointer"
                @click="openResourceModal(resource)"
              >
                <div class="w-12 h-12 sm:w-16 sm:h-16 bg-blue-50 flex-shrink-0">
                  <img 
                    v-if="resource.coverPhoto" 
                    :src="resource.coverPhoto" 
                    :alt="resource.name" 
                    class="w-full h-full object-cover" 
                  />
                  <div v-else class="w-12 h-12 sm:w-16 sm:h-16 flex items-center justify-center bg-blue-100">
                    <FileIcon class="w-4 h-4 sm:w-6 sm:h-6 text-blue-500" />
                  </div>
                </div>
                <div class="p-2 flex-1">
                  <h4 class="text-xs sm:text-sm font-medium line-clamp-2">{{ resource.name }}</h4>
                  <p class="text-xs text-gray-500 mt-1">{{ getReadTime(resource.description) }} min read</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useResourceCategoryStore } from '@/stores/modules/ResourceCategoryStore';
import { storeToRefs } from 'pinia';
import { 
  Clock as ClockIcon, 
  Calendar as CalendarIcon, 
  Phone as PhoneIcon,
  Plus as PlusIcon,
  PlusCircle,
  User as UserIcon,
  X as XIcon,
  Bookmark as BookmarkIcon,
  Share as ShareIcon,
  BookOpen as BookOpenIcon,
  File as FileIcon,
  Heart as HeartIcon,
  ChevronRight as ChevronRightIcon
} from 'lucide-vue-next';
import CalendarComponent from './dashboard/Calendar.vue';
import { useAuthStore } from '@/stores/modules/authStore';
import { usePetsStore } from '@/stores/modules/petsStore';
import { useAppointmentStore } from '@/stores/modules/appointmentStore';
import QueuePosition from '@/components/user/QueuePosition.vue';

const router = useRouter();

// Initialize the store
const resourceCategoryStore = useResourceCategoryStore();
const authStore = useAuthStore();

// Use storeToRefs to maintain reactivity when destructuring store state
const { 
  resourceCategories, // Using resourceCategories instead of categories
  resources, 
  loading: storeLoading, 
  error: storeError 
} = storeToRefs(resourceCategoryStore);

const isResourceModalOpen = ref(false);
const selectedResource = ref(null);
const isLoading = computed(() => storeLoading.value);

// Get pets store
const petsStore = usePetsStore();
const appointmentStore = useAppointmentStore();

// Computed properties
const displayedResources = computed(() => {
  return resources.value.slice(0, 6); // Show only 6 resources
});

const relatedResources = computed(() => {
  if (!selectedResource.value) return [];
  return resources.value
    .filter(r => r.id !== selectedResource.value.id && r.categoryId === selectedResource.value.categoryId)
    .slice(0, 3);
});

// Pets
const pets = ref([])
const petsLoading = ref(true) // Start with loading true
const petsError = ref(null)
const expandedPet = ref(null) // Track which pet is expanded
const appointments = ref([]) // Store user appointments

// Smart loading state that considers cache
const isPetsLoading = computed(() => {
  // If we have cached data, don't show loading
  if (petsStore.isDataCached(authStore.user?.userId)) {
    return false;
  }
  // Otherwise use the petsLoading state
  return petsLoading.value;
});

// Default pet photo URL with white background
const defaultPetPhotoURL = 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"%3E%3Crect width="24" height="24" fill="white"/%3E%3Cg fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"%3E%3Ccircle cx="11" cy="4" r="2"/%3E%3Ccircle cx="18" cy="8" r="2"/%3E%3Ccircle cx="20" cy="16" r="2"/%3E%3Cpath d="M9 10a5 5 0 0 1 5 5v3.5a3.5 3.5 0 0 1-6.84 1.045q-.64-2.065-2.7-2.705A3.5 3.5 0 0 1 5.5 10Z"/%3E%3C/g%3E%3C/svg%3E'

// Fetch real pets data
const fetchPets = async (forceRefresh = false) => {
  if (!authStore.user?.userId) {
    petsLoading.value = false
    return
  }
  
  petsLoading.value = true
  petsError.value = null
  
  try {
    // Use the pets store to fetch real data (store handles caching)
    await petsStore.fetchUserPets(authStore.user.userId, forceRefresh)
    
    // Get the fetched pets and format them for display
    const userPets = petsStore.getPets
    pets.value = userPets.map(pet => ({
      id: pet.id,
      name: pet.name || 'Unnamed Pet',
      image: pet.photoURL || defaultPetPhotoURL,
      breed: pet.breed || 'Unknown Breed',
      age: formatPetAge(pet),
      status: getPetStatus(pet),
      statusColor: getPetStatusColor(pet),
      // nextAppointment removed
      lastVisit: getLastVisitDate(pet.id),
      vaccinationCount: getVaccinationCount(pet),
      species: pet.species,
      weight: pet.weight,
      medicalHistory: pet.medicalHistory || [],
      vaccinations: pet.vaccinations || []
    }))
    
    // Also fetch appointments for the timeline
    await fetchUserAppointments()
  } catch (error) {
    console.error('Error fetching pets:', error)
    petsError.value = 'Failed to load pets'
    pets.value = []
  } finally {
    petsLoading.value = false
  }
}

// Fetch user appointments for timeline
const fetchUserAppointments = async (forceRefresh = false) => {
  if (!authStore.user?.userId) return
  
  try {
    // Use appointmentStore to fetch appointments with caching
    const userAppointments = await appointmentStore.fetchAppointmentsByUserId(authStore.user.userId, forceRefresh)
    appointments.value = userAppointments
    
    console.log('Fetched appointments:', appointments.value)
  } catch (error) {
    console.error('Error fetching appointments:', error)
    appointments.value = []
  }
}

// Helper functions for pet data
const formatPetAge = (pet) => {
  const parts = []
  if (pet.ageYears > 0) parts.push(`${pet.ageYears}y`)
  if (pet.ageMonths > 0) parts.push(`${pet.ageMonths}m`)
  if (pet.ageWeeks > 0) parts.push(`${pet.ageWeeks}w`)
  
  if (parts.length === 0) return 'Age not specified'
  return parts.join(' ')
}

const getPetStatus = (pet) => {
  // Check if pet has recent medical activity (appointments, medical history, or vaccinations)
  const hasRecentAppointments = appointments.value.some(apt => 
    apt.petIds && apt.petIds.includes(pet.id) && 
    apt.status === 'completed' &&
    new Date(apt.completedAt) > new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) // Last 30 days
  )
  
  const hasMedicalHistory = pet.medicalHistory && pet.medicalHistory.length > 0
  const hasVaccinations = pet.vaccinations && pet.vaccinations.length > 0
  
  if (hasRecentAppointments || hasMedicalHistory || hasVaccinations) {
    return 'active'
  }
  return 'inactive'
}

const getPetStatusColor = (pet) => {
  const status = getPetStatus(pet)
  const colors = {
    'active': 'text-green-700 bg-green-100',
    'inactive': 'text-gray-700 bg-gray-100'
  }
  return colors[status] || 'text-gray-700 bg-gray-100'
}

// getNextAppointment function removed

const getVaccinationCount = (pet) => {
  // Use the actual vaccinations array from the pet object
  if (pet.vaccinations && Array.isArray(pet.vaccinations)) {
    return pet.vaccinations.length.toString()
  }
  return '0'
}

const getLastVisitDate = (petId) => {
  const completedAppointments = appointments.value.filter(apt => 
    apt.petIds && apt.petIds.includes(petId) && 
    apt.status === 'completed'
  )
  
  if (completedAppointments.length === 0) return 'No visits yet'
  
  // Sort by completion date and get the most recent
  const lastVisit = completedAppointments.sort((a, b) => 
    new Date(b.completedAt) - new Date(a.completedAt)
  )[0]
  
  return formatDate(lastVisit.completedAt)
}

// Update todayAppointmentsCount to use real data
const todayAppointmentsCount = computed(() => {
  if (!appointments.value.length) return 0
  
  const today = new Date()
  const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate())
  const endOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 23, 59, 59, 999)
  
  return appointments.value.filter(apt => {
    const aptDate = new Date(apt.date)
    return aptDate >= startOfDay && aptDate <= endOfDay && apt.status === 'approved'
  }).length
})

// Manual refresh function
const refreshDashboardData = async () => {
  console.log('Manually refreshing dashboard data');
  try {
    await resourceCategoryStore.fetchResourceCategories({}, true); // Force refresh
    await resourceCategoryStore.fetchResources({}, true); // Force refresh
    await fetchPets(true); // Force refresh
    await fetchUserAppointments(true); // Force refresh
  } catch (error) {
    console.error('Error refreshing dashboard data:', error);
  }
};

// Fetch resources on component mount
onMounted(async () => {
  try {
    // Check if we already have data in stores
    const hasResourceData = resourceCategories.value && resourceCategories.value.length > 0 &&
                           resources.value && resources.value.length > 0;
    const hasPetsData = petsStore.isDataCached(authStore.user?.userId);
    const hasAppointmentsData = appointmentStore.isDataCached(authStore.user?.userId);
    
    console.log('Dashboard mounted - checking cache:', {
      hasResourceData,
      hasPetsData,
      hasAppointmentsData,
      storeLoading: storeLoading.value,
      petsLoading: petsLoading.value,
      petsInStore: petsStore.getPets?.length || 0,
      isPetsCached: petsStore.isDataCached(authStore.user?.userId),
      isAppointmentsCached: appointmentStore.isDataCached(authStore.user?.userId)
    });
    
    if (hasResourceData && hasPetsData && hasAppointmentsData) {
      // All data exists, just format pets data without loading
      console.log('Using cached data - no loading needed');
      petsLoading.value = false; // Set loading to false immediately
      
      // Format pets data from store without triggering loading
      const userPets = petsStore.getPets;
      pets.value = userPets.map(pet => ({
        id: pet.id,
        name: pet.name || 'Unnamed Pet',
        image: pet.photoURL || defaultPetPhotoURL,
        breed: pet.breed || 'Unknown Breed',
        age: formatPetAge(pet),
        status: getPetStatus(pet),
        statusColor: getPetStatusColor(pet),
        lastVisit: getLastVisitDate(pet.id),
        vaccinationCount: getVaccinationCount(pet),
        species: pet.species,
        weight: pet.weight,
        medicalHistory: pet.medicalHistory || [],
        vaccinations: pet.vaccinations || []
      }));
      
      // Get appointments from store without triggering loading
      const userAppointments = appointmentStore.getAppointmentsByUserId(authStore.user.userId);
      appointments.value = userAppointments;
      return;
    }

    // Need to fetch fresh data
    console.log('Fetching fresh data');
    await resourceCategoryStore.fetchResourceCategories();
    await resourceCategoryStore.fetchResources();
    await fetchPets(); // Fetch pets and appointments
  } catch (error) {
    console.error('Error fetching resources:', error);
  }
});

// Pet expansion functionality
const togglePetExpansion = (petId) => {
  if (expandedPet.value === petId) {
    expandedPet.value = null
  } else {
    expandedPet.value = petId
  }
}

// Get appointments for a specific pet
const getPetAppointments = (petId) => {
  if (!appointments.value || appointments.value.length === 0) return []
  
  // Filter appointments for this specific pet
  return appointments.value.filter(apt => 
    apt.petIds && apt.petIds.includes(petId)
  ).sort((a, b) => {
    // Sort by date, most recent first
    const dateA = a.date instanceof Date ? a.date : new Date(a.date)
    const dateB = b.date instanceof Date ? b.date : new Date(b.date)
    return dateB - dateA
  })
}

// Format appointment date for display
const formatAppointmentDate = (date) => {
  if (!date) return 'No date'
  
  try {
    const appointmentDate = date instanceof Date ? date : new Date(date)
    return appointmentDate.toLocaleDateString('en-US', { 
      month: 'short', 
      day: 'numeric',
      year: 'numeric'
    })
  } catch (error) {
    return 'Invalid date'
  }
}

// Helper functions
const typeColors = {
    'Document': 'bg-blue-100 text-blue-600',
    'Video': 'bg-red-100 text-red-600',
    'Audio': 'bg-purple-100 text-purple-600',
    'Image': 'bg-green-100 text-green-600',
    'Other': 'bg-gray-100 text-gray-600'
  };

// Open resource modal
function openResourceModal(resource) {
  selectedResource.value = resource;
  isResourceModalOpen.value = true;
  document.body.style.overflow = 'hidden'; // Prevent scrolling when modal is open
}

// Close resource modal
function closeResourceModal() {
  selectedResource.value = null;
  isResourceModalOpen.value = false;
  document.body.style.overflow = ''; // Restore scrolling
}

const getTagColor = (type) => {
  const colors = {
    'Article': 'bg-blue-100 text-blue-700',
    'Video': 'bg-green-100 text-green-700',
    'Guide': 'bg-purple-100 text-purple-700',
    'Infographic': 'bg-orange-100 text-orange-700'
  };
  return colors[type] || 'bg-gray-100 text-gray-700';
};

const getReadTime = (description) => {
  if (!description) return 2;
  const wordCount = description.split(' ').length;
  return Math.ceil(wordCount / 200); // Assuming 200 words per minute reading speed
};

const getCategoryName = (categoryId) => {
  const category = resourceCategories.value.find(cat => cat.id === categoryId);
  return category ? category.name : 'General';
};

const formatDate = (date) => {
  if (!date) return 'Unknown date';
  return new Date(date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
};

const formatDescription = (description) => {
  if (!description) return '';
  return description.replace(/\n/g, '<br>');
};

const getStatusColor = (status) => {
  const colors = {
    'active': 'text-green-700 bg-green-100',
    'inactive': 'text-gray-700 bg-gray-100',
    'pending': 'text-yellow-700 bg-yellow-100',
    'suspended': 'text-red-700 bg-red-100'
  };
  return colors[status] || 'text-gray-700 bg-gray-100';
};
</script>

<style scoped>
/* Add any additional custom styles here */
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2; /* Add this standard property */
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.prose {
  color: #374151;
  max-width: 65ch;
  font-size: 1rem;
  line-height: 1.75;
}

.prose p {
  margin-top: 1.25em;
  margin-bottom: 1.25em;
}

.prose h2 {
  color: #111827;
  font-weight: 700;
  font-size: 1.5em;
  margin-top: 2em;
  margin-bottom: 1em;
  line-height: 1.3333333;
}

.prose h3 {
  color: #111827;
  font-weight: 600;
  font-size: 1.25em;
  margin-top: 1.6em;
  margin-bottom: 0.6em;
  line-height: 1.6;
}

.prose ul {
  margin-top: 1.25em;
  margin-bottom: 1.25em;
  padding-left: 1.625em;
  list-style-type: disc;
}

.prose li {
  margin-top: 0.5em;
  margin-bottom: 0.5em;
}

.prose strong {
  font-weight: 600;
  color: #111827;
}
</style>


