<template>
  <div class="w-full">
    <!-- Enhanced Page Header -->
    <div class="bg-white border-b border-gray-200 px-2 sm:px-4 md:px-6 py-4 sm:py-6">
      <div class="max-w-7xl mx-auto">
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 sm:gap-4">
          <div class="flex-1 min-w-0">
            <h1 class="text-lg sm:text-xl md:text-2xl lg:text-3xl font-bold text-gray-900 break-words">My Pets</h1>
            <p class="text-xs sm:text-sm md:text-base lg:text-lg text-gray-600 mt-1 sm:mt-2 break-words">Manage your pets and view their health records</p>
          </div>
          <div class="flex justify-end sm:justify-start">
            <button
              @click.prevent="addNewPet"
              :disabled="hasUnsavedNewPet"
              :class="[
                'px-4 py-2 sm:px-3 sm:py-1.5 md:px-4 md:py-2 rounded-full text-[10px] sm:text-xs md:text-sm font-medium transition-colors flex items-center justify-center w-auto flex-shrink-0',
                hasUnsavedNewPet 
                  ? 'bg-gray-300 text-gray-500 cursor-not-allowed' 
                  : 'bg-blue-500 text-white hover:bg-blue-600'
              ]"
              type="button"
              :title="hasUnsavedNewPet ? 'Please save the current pet before adding a new one' : 'Add a new pet'"
            >
              <PlusCircle class="w-3 h-3 sm:w-4 sm:h-4 mr-1 sm:mr-2" />
              <span class="hidden sm:inline">Add Pet</span>
              <span class="sm:hidden">Add</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Main Content Area -->
    <div class="flex-1 px-2 sm:px-4 md:px-6 py-4 sm:py-6">
      <div class="max-w-7xl mx-auto">
        <LoadingSpinner v-if="isLoading" isOverlay text="Loading pets data..." />
        
        <!-- Initial Data Loading State (only show if not adding a new pet) -->
        <div v-if="!isLoading && initialLoading && !selectedPetId" class="grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-3 gap-2 sm:gap-3 md:gap-4">
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

        <div v-else-if="!isLoading || selectedPetId" class="space-y-6">
          <!-- List view -->
          <div v-if="!selectedPetId">
            <!-- Empty State -->
            <div v-if="localPets.length === 0" class="text-center py-8 sm:py-12 md:py-16">
              <div class="w-16 h-16 sm:w-20 sm:h-20 md:w-24 md:h-24 bg-blue-50 rounded-full flex items-center justify-center mx-auto mb-4 sm:mb-6">
                <HeartIcon class="w-8 h-8 sm:w-10 sm:h-10 md:w-12 md:h-12 text-blue-400" />
              </div>
              <h3 class="text-lg sm:text-xl md:text-2xl font-semibold text-gray-900 mb-2 sm:mb-3">No pets added yet</h3>
              <p class="text-sm sm:text-base text-gray-600 mb-6 sm:mb-8 max-w-md mx-auto px-4">Start your journey with ProVET by adding your first pet. We'll help you track their health, vaccinations, and medical history.</p>
              <button
                @click.prevent="addNewPet"
                class="px-4 sm:px-6 md:px-8 py-2 sm:py-3 md:py-4 bg-blue-600 text-white rounded-lg sm:rounded-xl font-semibold hover:bg-blue-700 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105 text-sm sm:text-base"
              >
                <PlusIcon class="w-4 h-4 sm:w-5 sm:h-5 mr-1 sm:mr-2 inline" />
                Add Your First Pet
              </button>
            </div>
            
            <!-- Pets Grid -->
            <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
              <div
                v-for="(pet, index) in localPets"
                :key="pet.id || pet.tempId"
                class="group relative overflow-hidden rounded-xl sm:rounded-2xl border bg-white shadow-sm hover:shadow-xl transition-all duration-300 hover:scale-[1.02] flex flex-col h-full"
              >
                <!-- Card Content -->
                <div class="flex flex-col h-full">
                  <!-- Header with avatar -->
                  <div class="p-4 sm:p-5 pt-6 sm:pt-7 flex-1">
                    <!-- Mobile Layout: Stack vertically on small screens -->
                    <div class="flex flex-col sm:flex-row sm:items-start gap-3 sm:gap-4">
                      <!-- Avatar and basic info -->
                      <div class="flex items-start gap-4 sm:gap-6 flex-1">
                        <div class="relative -mt-2 sm:-mt-3 w-16 h-16 sm:w-20 sm:h-20 rounded-full overflow-hidden ring-2 sm:ring-4 ring-white shadow-lg flex-shrink-0">
                          <img :src="pet.photoURL || defaultPetPhotoURL" :alt="pet.name" class="w-full h-full object-cover" />
                        </div>
                        <div class="flex-1 min-w-0">
                          <!-- Pet name and status - allow wrapping on small screens -->
                          <div class="flex flex-col sm:flex-row sm:items-center gap-1 sm:gap-2 mb-1 sm:mb-2">
                            <h3 class="text-base sm:text-lg md:text-xl font-bold text-gray-900 break-words">{{ pet.isNew ? 'New Pet' : pet.name }}</h3>
                            <span v-if="pet.isNew" class="px-1.5 sm:px-2 py-0.5 sm:py-1 rounded-full bg-yellow-100 text-yellow-700 text-xs font-medium self-start">New</span>
                          </div>
                          <!-- Pet details - stack on small screens -->
                          <div class="space-y-1">
                            <p class="text-xs sm:text-sm text-gray-600 break-words">{{ pet.breed || 'No breed' }} • {{ formatPetAge(pet) }}</p>
                            <p class="text-xs text-gray-500 break-words">{{ pet.species || 'Species not specified' }}</p>
                          </div>
                        </div>
                      </div>
                      <!-- Action buttons - always visible but smaller on mobile -->
                      <div class="flex items-center gap-1 sm:gap-2 self-start sm:self-auto">
                        <button v-if="!pet.isNew" @click.stop="viewPet(pet)" class="p-1.5 sm:p-2 rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-100 transition-colors" title="View">
                          <EyeIcon class="w-3 h-3 sm:w-4 sm:h-4" />
                        </button>
                        <button @click.stop="editPet(pet)" class="p-1.5 sm:p-2 rounded-lg bg-gray-50 text-gray-700 hover:bg-gray-100 transition-colors" title="Edit">
                          <EditIcon class="w-3 h-3 sm:w-4 sm:h-4" />
                        </button>
                        <button v-if="!pet.isNew" @click.stop="confirmDeletePet(pet)" class="p-1.5 sm:p-2 rounded-lg bg-red-50 text-red-600 hover:bg-red-100 transition-colors" title="Delete">
                          <Trash2 class="w-3 h-3 sm:w-4 sm:h-4" />
                        </button>
                      </div>
                    </div>

                    <!-- Info grid -->
                    <div class="mt-3 sm:mt-4 grid grid-cols-2 gap-2 sm:gap-3">
                      <div class="rounded-lg sm:rounded-xl border bg-gray-50 p-2 sm:p-3">
                        <div class="text-xs uppercase tracking-wide text-gray-500 font-medium mb-1">Species</div>
                        <div class="text-sm sm:text-base font-semibold text-gray-800">{{ pet.species || '—' }}</div>
                      </div>
                      <div class="rounded-lg sm:rounded-xl border bg-gray-50 p-2 sm:p-3">
                        <div class="text-xs uppercase tracking-wide text-gray-500 font-medium mb-1">Gender</div>
                        <div class="text-sm sm:text-base font-semibold text-gray-800">{{ pet.gender ? formatGender(pet.gender) : '—' }}</div>
                      </div>
                      <div class="rounded-lg sm:rounded-xl border bg-gray-50 p-2 sm:p-3">
                        <div class="text-xs uppercase tracking-wide text-gray-500 font-medium mb-1">Weight</div>
                        <div class="text-sm sm:text-base font-semibold text-gray-800">{{ pet.weight ? pet.weight + ' kg' : '—' }}</div>
                      </div>
                        <div class="rounded-lg sm:rounded-xl border bg-gray-50 p-2 sm:p-3">
                          <div class="text-xs uppercase tracking-wide text-gray-500 font-medium mb-1">Records</div>
                          <div class="text-sm sm:text-base font-semibold text-blue-600">{{ getPetRecordsCount(pet) }}</div>
                        </div>
                    </div>
                  </div>

                  <!-- Footer - Always at bottom -->
                  <div class="p-3 sm:p-4 pt-0 mt-auto">
                    <div class="flex flex-col sm:flex-row items-start sm:items-end justify-between gap-3 sm:gap-0">
                      <div class="flex flex-wrap gap-2 sm:gap-3 flex-1">
                        <span class="px-2 sm:px-3 py-1 rounded-full bg-blue-100 text-blue-700 text-xs font-medium">{{ pet.species || 'Species' }}</span>
                        <span class="px-2 sm:px-3 py-1 rounded-full bg-green-100 text-green-700 text-xs font-medium">{{ pet.breed || 'Breed' }}</span>
                      </div>
                      <router-link :to="`/user/userappointments?petId=${pet.id}`" class="px-2 sm:px-3 py-1.5 sm:py-2 rounded-full bg-white text-blue-600 text-xs sm:text-sm font-medium hover:bg-blue-50 transition-colors border border-blue-200 w-full sm:w-auto text-center flex-shrink-0">
                        Book Appointment
                      </router-link>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Details view -->
      <div v-if="selectedPetId" class="space-y-3 sm:space-y-4 md:space-y-6">
        <!-- Enhanced Header -->
        <div class="bg-white rounded-xl sm:rounded-2xl shadow-sm border border-gray-200 p-3 sm:p-4 md:p-6">
          <div class="flex flex-col items-start gap-3 sm:gap-4 md:gap-6">
            <!-- Back button and title row -->
            <div class="flex items-center justify-between w-full">
              <button @click="backToList" type="button" class="p-1.5 sm:p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-lg transition-colors">
                <ArrowLeftIcon class="w-4 h-4 sm:w-5 sm:h-5 md:w-6 md:h-6" />
              </button>
              <div class="flex-1 text-center sm:text-left">
                <p v-if="selectedLocalPet?.isNew" class="text-xs sm:text-sm md:text-base text-gray-600 break-words">Complete the form and save to view details</p>
              </div>
              <button v-if="viewMode === 'view' && selectedPetTab === 'basic-details'" @click="editPet(selectedLocalPet)" type="button" class="px-2 sm:px-3 md:px-4 py-1.5 sm:py-2 text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-full transition-colors flex items-center justify-center gap-1 sm:gap-2 text-xs sm:text-sm md:text-base">
                <EditIcon class="w-3 h-3 sm:w-4 sm:h-4" />
                <span class="hidden sm:inline">Edit Pet</span>
                <span class="sm:hidden">Edit</span>
              </button>
            </div>
            
            <!-- Pet photo and info row -->
            <div class="flex items-center gap-3 sm:gap-4 md:gap-6 w-full">
              <div class="relative group flex-shrink-0">
                <div class="w-16 h-16 sm:w-20 sm:h-20 md:w-24 md:h-24 rounded-full overflow-hidden ring-2 sm:ring-4 ring-white shadow-lg">
                  <img :src="selectedLocalPet?.photoURL || defaultPetPhotoURL" :alt="selectedLocalPet?.name" class="w-full h-full object-cover" />
                </div>
                <button v-if="viewMode === 'edit'" @click.prevent="triggerPetPhotoUpload" type="button" class="absolute bottom-0 right-0 bg-white rounded-full p-1 sm:p-1.5 md:p-2 shadow-md hover:bg-gray-100 transition-colors">
                  <CameraIcon class="w-2.5 h-2.5 sm:w-3 sm:h-3 md:w-4 md:h-4 text-gray-600" />
                </button>
              </div>
              
              <!-- Pet name and info display -->
              <div class="flex-1">
                <h2 class="text-base sm:text-lg md:text-xl lg:text-2xl font-bold text-gray-900 break-words mb-1">{{ getSavedPetName() }}</h2>
                <div class="text-sm sm:text-base text-gray-600">
                  {{ getSavedPetDetails() }}
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <!-- Tabs -->
        <div v-if="!selectedLocalPet?.isNew && viewMode === 'view'" class="bg-white rounded-xl sm:rounded-2xl shadow-sm border border-gray-200 overflow-hidden">
          <nav class="flex border-b border-gray-200 overflow-x-auto">
            <button v-for="tab in petTabs" :key="tab.id" @click.prevent="handleTabClick(tab.id)" type="button" :class="['py-2 sm:py-3 md:py-4 px-3 sm:px-4 md:px-6 border-b-2 font-medium text-xs sm:text-sm whitespace-nowrap flex items-center gap-1 sm:gap-2 transition-colors flex-shrink-0', selectedPetTab === tab.id ? 'border-blue-500 text-blue-600 bg-blue-50' : 'border-transparent text-gray-500 hover:text-gray-700 hover:bg-gray-50']">
              <component :is="tab.icon" class="w-3 h-3 sm:w-4 sm:h-4 md:w-5 md:h-5" />
              {{ tab.name }}
            </button>
          </nav>
        </div>
        
        <!-- Tab Content -->
        <div class="bg-white rounded-xl sm:rounded-2xl shadow-sm border border-gray-200 p-3 sm:p-4 md:p-6">
          <!-- Basic Details -->
          <div v-if="viewMode === 'edit' || (viewMode === 'view' && selectedPetTab === 'basic-details')" class="space-y-3 sm:space-y-4 md:space-y-6">
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 sm:gap-3 md:gap-4 lg:gap-6">
              <div>
                <label class="block text-xs sm:text-sm font-medium text-gray-700 mb-0.5 sm:mb-1">Name <span class="text-red-500">*</span></label>
                <input v-model="editablePet.name" type="text" placeholder="Enter pet name" class="w-full px-2 sm:px-3 py-1.5 sm:py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-1 focus:ring-gray-200 text-xs sm:text-base transition-colors" @input="updateLocalPet" :disabled="viewMode === 'view'" />
              </div>
              <div>
                <label class="block text-xs sm:text-sm font-medium text-gray-700 mb-0.5 sm:mb-1">Species <span class="text-red-500">*</span></label>
                <input v-model="editablePet.species" type="text" placeholder="Enter species" class="w-full px-2 sm:px-3 py-1.5 sm:py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-1 focus:ring-gray-200 text-xs sm:text-base transition-colors" @input="updateLocalPet" :disabled="viewMode === 'view'" />
              </div>
              <div>
                <label class="block text-xs sm:text-sm font-medium text-gray-700 mb-0.5 sm:mb-1">Breed <span class="text-red-500">*</span></label>
                <input v-model="editablePet.breed" type="text" placeholder="Enter breed" class="w-full px-2 sm:px-3 py-1.5 sm:py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-1 focus:ring-gray-200 text-xs sm:text-base transition-colors" @input="updateLocalPet" :disabled="viewMode === 'view'" />
              </div>
              <div class="sm:col-span-2">
                <label class="block text-xs sm:text-sm font-medium text-gray-700 mb-0.5 sm:mb-1">Age (Years, Months, Weeks)</label>
                <div class="grid grid-cols-3 gap-1.5 sm:gap-2 md:gap-3">
                  <div>
                    <input v-model.number="editablePet.ageYears" type="number" min="0" placeholder="Years" class="w-full px-2 sm:px-3 py-1.5 sm:py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-1 focus:ring-gray-200 text-xs sm:text-base transition-colors" @input="updateLocalPet" :disabled="viewMode === 'view'" />
                    <label class="block text-xs text-gray-500 mt-0.5 text-center">Years</label>
                  </div>
                  <div>
                    <input v-model.number="editablePet.ageMonths" type="number" min="0" max="11" placeholder="Months" class="w-full px-2 sm:px-3 py-1.5 sm:py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-1 focus:ring-gray-200 text-xs sm:text-base transition-colors" @input="updateLocalPet" :disabled="viewMode === 'view'" />
                    <label class="block text-xs text-gray-500 mt-0.5 text-center">Months</label>
                  </div>
                  <div>
                    <input v-model.number="editablePet.ageWeeks" type="number" min="0" max="3" placeholder="Weeks" class="w-full px-2 sm:px-3 py-1.5 sm:py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-1 focus:ring-gray-200 text-xs sm:text-base transition-colors" @input="updateLocalPet" :disabled="viewMode === 'view'" />
                    <label class="block text-xs text-gray-500 mt-0.5 text-center">Weeks</label>
                  </div>
                </div>
              </div>
              <div>
                <label class="block text-xs sm:text-sm font-medium text-gray-700 mb-0.5 sm:mb-1">Weight (kg)</label>
                <input v-model.number="editablePet.weight" type="number" step="0.1" placeholder="Enter weight" class="w-full px-2 sm:px-3 py-1.5 sm:py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-1 focus:ring-gray-200 text-xs sm:text-base transition-colors" @input="updateLocalPet" :disabled="viewMode === 'view'" />
              </div>
              <div>
                <label class="block text-xs sm:text-sm font-medium text-gray-700 mb-0.5 sm:mb-1">Gender <span class="text-red-500">*</span></label>
                <div v-if="viewMode !== 'view'" class="relative">
                  <div @click="toggleGenderDropdown" class="w-full px-2 sm:px-3 py-1.5 sm:py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-1 focus:ring-gray-200 text-xs sm:text-base cursor-pointer flex justify-between items-center gender-dropdown transition-colors">
                    <span v-if="editablePet.gender">{{ formatGender(editablePet.gender) }}</span>
                    <span v-else class="text-gray-500">Select gender</span>
                    <ChevronDownIcon class="w-3 h-3 sm:w-4 sm:h-4 text-gray-500" :class="{ 'transform rotate-180': genderDropdownOpen }" />
                  </div>
                  <div v-show="genderDropdownOpen" class="absolute z-10 mt-1 w-full bg-white border border-gray-200 rounded-lg shadow-lg gender-dropdown">
                    <div v-for="option in genderOptions" :key="option.value" @click="selectGender(option.value)" class="px-3 sm:px-4 py-2 sm:py-3 hover:bg-gray-100 cursor-pointer text-xs sm:text-sm gender-dropdown transition-colors">{{ option.label }}</div>
                  </div>
                </div>
                <div v-else class="w-full px-2 sm:px-3 py-1.5 sm:py-2 border border-gray-300 rounded-lg bg-gray-50 text-xs sm:text-base">{{ editablePet.gender ? formatGender(editablePet.gender) : 'Not specified' }}</div>
              </div>
            </div>
            
            <!-- Action Buttons for Edit Mode -->
            <div v-if="viewMode === 'edit'" class="flex flex-row justify-end space-x-2 sm:space-x-4 pt-3 sm:pt-4 md:pt-6 border-t border-gray-200">
              <button
                @click="cancelChanges"
                type="button"
                class="px-2 sm:px-3 py-1.5 sm:py-2 rounded-full bg-red-200 text-red-800 hover:bg-red-300 transition-colors text-xs sm:text-sm font-medium min-h-[36px] touch-manipulation"
              >
                Cancel
              </button>
              <button
                @click="saveAllChanges"
                :disabled="isSavingChanges || !pendingChanges"
                :class="[
                  'px-2 sm:px-4 py-1.5 sm:py-2 rounded-full transition-colors flex items-center justify-center gap-1 sm:gap-2 text-xs sm:text-sm font-medium min-h-[36px] touch-manipulation',
                  isSavingChanges || !pendingChanges
                    ? 'bg-gray-300 text-gray-500 cursor-not-allowed'
                    : 'bg-blue-500 text-white hover:bg-blue-700'
                ]"
              >
                <div v-if="isSavingChanges" class="w-3 h-3 sm:w-4 sm:h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                {{ isSavingChanges ? 'Saving...' : 'Save Changes' }}
              </button>
            </div>
          </div>
          
          <!-- Medical History Tab Content -->
          <div v-if="selectedPetTab === 'medical-history' && !selectedLocalPet?.isNew" class="space-y-3 sm:space-y-4 md:space-y-6">
            <!-- Header with Actions -->
            <div class="flex flex-col gap-3 sm:gap-4">
              <div>
                <h3 class="text-base sm:text-lg md:text-xl font-semibold text-gray-900">Medical History</h3>
                <p class="text-xs sm:text-sm text-gray-600 mt-1">Complete medical records, vaccinations, and appointment history</p>
              </div>
              <div class="flex items-center gap-2 w-full sm:w-auto">
                <!-- View Vaccination Card Button -->
                <button 
                  @click="openVaccinationCardModal"
                  class="px-3 sm:px-4 py-2 sm:py-2.5 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors flex items-center gap-2 text-sm sm:text-base w-full sm:w-auto justify-center font-medium"
                >
                  <ShieldIcon class="w-4 h-4 sm:w-5 sm:h-5" />
                  <span class="hidden sm:inline">View Vaccination Card</span>
                  <span class="sm:hidden">Vaccination Card</span>
                </button>
              </div>
            </div>

            <!-- Enhanced Filter Buttons -->
            <div class="flex flex-wrap gap-1.5 sm:gap-2 md:gap-3">
              <!-- Loading state for categories -->
              <div v-if="categories.length === 0" class="flex items-center gap-2 px-2 sm:px-3 md:px-4 py-1.5 sm:py-2 bg-gray-100 text-gray-600 rounded-lg">
                <div class="w-3 h-3 sm:w-4 sm:h-4 border-2 border-gray-300 border-t-gray-600 rounded-full animate-spin"></div>
                <span class="text-xs sm:text-sm">Loading categories...</span>
              </div>
              <button
                @click="setHistoryFilter('all')"
                :class="[
                  'px-2 sm:px-3 md:px-4 py-1.5 sm:py-2 rounded-lg text-xs sm:text-sm font-medium transition-all duration-200 flex items-center gap-1 sm:gap-2',
                  historyFilter === 'all'
                    ? 'bg-blue-500 text-white shadow-md'
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200 hover:shadow-sm'
                ]"
              >
                <ActivityIcon class="w-3 h-3 sm:w-4 sm:h-4" />
                <span class="hidden sm:inline">All Records</span>
                <span class="sm:hidden">All</span>
              </button>
              <!-- Service Category Filters -->
              <div class="w-full border-t border-gray-200 pt-2 sm:pt-3 mt-2">
                <div class="text-xs sm:text-sm font-medium text-gray-600 mb-1.5 sm:mb-2">Service Categories:</div>
                <div class="flex flex-wrap gap-1 sm:gap-1.5 md:gap-2">
                  <button
                    v-for="category in categories"
                    :key="category.id"
                    @click="setHistoryFilter(category.id)"
                    :class="[
                      'px-2 sm:px-3 py-1.5 sm:py-2 rounded-lg text-xs sm:text-sm font-medium transition-all duration-200 flex items-center gap-1 sm:gap-2',
                      historyFilter === category.id
                        ? 'bg-purple-500 text-white shadow-md'
                        : 'bg-gray-100 text-gray-600 hover:bg-gray-200 hover:shadow-sm'
                    ]"
                    :title="category.description"
                  >
                    <div class="w-2 h-2 sm:w-3 sm:h-3 rounded-full" :class="{
                      'bg-blue-500': category.id === 'telehealth5192',
                      'bg-green-500': category.id === 'elective3401',
                      'bg-orange-500': category.id === 'veterinary8515',
                      'bg-red-500': category.id === 'walk-in8438',
                      'bg-purple-500': !['telehealth5192', 'elective3401', 'veterinary8515', 'walk-in8438'].includes(category.id)
                    }"></div>
                    <span class="hidden sm:inline">{{ category.name }}</span>
                    <span class="sm:hidden">{{ category.name.split(' ')[0] }}</span>
                  </button>
                </div>
              </div>
              
              <button
                @click="setHistoryFilter('completed')"
                :class="[
                  'px-2 sm:px-3 md:px-4 py-1.5 sm:py-2 rounded-lg text-xs sm:text-sm font-medium transition-all duration-200 flex items-center gap-1 sm:gap-2',
                  historyFilter === 'completed'
                    ? 'bg-green-500 text-white shadow-md'
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200 hover:shadow-sm'
                ]"
              >
                <svg class="w-3 h-3 sm:w-4 sm:h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                <span class="hidden sm:inline">Completed Appointments</span>
                <span class="sm:hidden">Completed</span>
              </button>

              <!-- Clear Filter Button -->
              <button
                v-if="historyFilter !== 'all'"
                @click="setHistoryFilter('all')"
                class="px-2 sm:px-3 md:px-4 py-1.5 sm:py-2 rounded-lg text-xs sm:text-sm font-medium transition-all duration-200 bg-gray-200 text-gray-700 hover:bg-gray-300 hover:shadow-sm flex items-center gap-1 sm:gap-2"
              >
                <XIcon class="w-3 h-3 sm:w-4 sm:h-4" />
                <span class="hidden sm:inline">Clear Filter</span>
                <span class="sm:hidden">Clear</span>
              </button>
            </div>

            <!-- Record Counter and Stats -->
            <div class="bg-gray-50 rounded-lg p-2 sm:p-3 md:p-4">
              <div class="flex flex-col gap-2 sm:gap-3">
                <div class="grid grid-cols-2 sm:grid-cols-4 gap-2 sm:gap-3 md:gap-6">
                  <div class="text-center bg-white rounded-lg p-2 sm:p-3">
                    <div class="text-base sm:text-lg md:text-xl font-bold text-gray-900">{{ timelineEntries.length }}</div>
                    <div class="text-xs sm:text-sm text-gray-500">Total Records</div>
                  </div>
                  <div class="text-center bg-white rounded-lg p-2 sm:p-3">
                    <div class="text-sm sm:text-base md:text-lg font-semibold text-blue-600">{{ petAppointments.length }}</div>
                    <div class="text-xs sm:text-sm text-gray-500">Total Appointments</div>
                  </div>
                  <div class="text-center bg-white rounded-lg p-2 sm:p-3">
                    <div class="text-sm sm:text-base md:text-lg font-semibold text-green-600">{{ petAppointments.filter(a => a.status === 'completed').length }}</div>
                    <div class="text-xs sm:text-sm text-gray-500">Completed</div>
                  </div>
                  <div class="text-center bg-white rounded-lg p-2 sm:p-3">
                    <div class="text-sm sm:text-base md:text-lg font-semibold text-purple-600">{{ categories.length }}</div>
                    <div class="text-xs sm:text-sm text-gray-500">Categories</div>
                  </div>
                </div>
                <div class="text-xs sm:text-sm text-gray-600 text-center sm:text-left">
                  <span v-if="historyFilter !== 'all'">Filtered by: {{ 
                    historyFilter === 'completed' ? 'Completed Appointments' :
                    categories.find(cat => cat.id === historyFilter)?.name || 'Unknown Category'
                  }}</span>
                </div>
              </div>
            </div>

            <!-- Loading and Error States -->
            <div v-if="historyLoading" class="py-8 sm:py-12 text-center">
              <div class="animate-spin rounded-full h-8 w-8 sm:h-12 sm:w-12 border-b-2 border-blue-500 mx-auto mb-3 sm:mb-4"></div>
              <p class="text-sm sm:text-base text-gray-500">Loading medical records...</p>
              <p class="text-xs sm:text-sm text-gray-400 mt-1 sm:mt-2">This may take a few seconds on first load</p>
            </div>
            
            <div v-else-if="historyError" class="bg-red-50 border border-red-200 text-red-600 p-4 sm:p-6 rounded-lg text-center">
              <div class="w-10 h-10 sm:w-12 sm:h-12 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-2 sm:mb-3">
                <XIcon class="w-5 h-5 sm:w-6 sm:h-6 text-red-500" />
              </div>
              <p class="text-sm sm:text-base font-medium">{{ historyError }}</p>
              <button @click="fetchPetAppointments" class="mt-2 sm:mt-3 px-3 sm:px-4 py-1.5 sm:py-2 bg-red-100 text-red-700 rounded-lg hover:bg-red-200 text-xs sm:text-sm">
                Try Again
              </button>
            </div>

            <!-- Records Timeline -->
            <div v-else>
              <!-- Loading state for timeline -->
              <div v-if="historyLoading" class="text-center py-12">
                <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto mb-4"></div>
                <p class="text-gray-500">Loading timeline...</p>
              </div>
              
              <div v-else-if="timelineEntries.length === 0" class="text-center py-8 sm:py-12">
                <div class="w-12 h-12 sm:w-16 sm:h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-3 sm:mb-4">
                  <component
                    :is="historyFilter === 'vaccinations' ? ShieldIcon :
                         historyFilter === 'telehealth' ? ActivityIcon :
                         historyFilter === 'treatments' ? ActivityIcon : ActivityIcon"
                    class="w-6 h-6 sm:w-8 sm:h-8 text-gray-400"
                  />
                </div>
                <h3 class="text-base sm:text-lg font-medium text-gray-900 mb-1 sm:mb-2">
                  {{ historyFilter === 'all' ? 'No appointments yet' :
                     historyFilter === 'completed' ? 'No completed appointments found' :
                     categories.find(cat => cat.id === historyFilter) ? `No ${categories.find(cat => cat.id === historyFilter).name} appointments found` :
                     'No appointments found' }}
                </h3>
                <p class="text-sm sm:text-base text-gray-500 max-w-md mx-auto px-4">
                  {{ historyFilter === 'all' ? 'Appointments will appear here once they are scheduled and completed.' :
                     historyFilter === 'completed' ? 'Completed appointments with detailed notes will appear here once your veterinarian completes them.' :
                     categories.find(cat => cat.id === historyFilter) ? `${categories.find(cat => cat.id === historyFilter).name} appointments will appear here once they are scheduled and completed.` :
                     'Appointments will appear here once they are scheduled.' }}
                </p>
              </div>
              
              <!-- Enhanced Timeline -->
              <div v-else class="relative">
                <div class="absolute left-3 sm:left-4 top-0 bottom-0 w-0.5 bg-gray-200"></div>
                <div class="space-y-4 sm:space-y-6">
                  <div v-for="(e, idx) in timelineEntries" :key="idx" class="relative pl-6 sm:pl-8">
                    <!-- Timeline Dot -->
                    <div class="absolute left-0 w-3 h-3 sm:w-4 sm:h-4 rounded-full border-2 border-white shadow-sm flex items-center justify-center" :class="{
                      'bg-green-500': e.kind === 'Vaccination' && e.status === 'completed',
                      'bg-yellow-500': e.kind === 'Vaccination' && e.status === 'pending',
                      'bg-blue-500': e.kind === 'Telehealth',
                      'bg-emerald-500': e.kind === 'Treatment',
                      'bg-indigo-500': e.kind === 'Appointment'
                    }">
                      <component :is="e.icon" class="w-2 h-2 sm:w-2.5 sm:h-2.5 text-white" />
                    </div>
                    
                    <!-- Timeline Content -->
                    <div class="bg-white rounded-lg border border-gray-200 p-3 sm:p-4 hover:shadow-md transition-shadow duration-200">
                      <div class="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-2 sm:gap-0 mb-2">
                        <div class="flex flex-wrap items-center gap-1 sm:gap-2">
                          <span class="text-xs font-medium px-1.5 sm:px-2 py-0.5 sm:py-1 rounded-full" :class="{
                            'bg-green-100 text-green-700': e.kind === 'Vaccination' && e.status === 'completed',
                            'bg-yellow-100 text-yellow-700': e.kind === 'Vaccination' && e.status === 'pending',
                            'bg-blue-100 text-blue-700': e.kind === 'Telehealth',
                            'bg-emerald-100 text-emerald-700': e.kind === 'Treatment',
                            'bg-indigo-100 text-indigo-700': e.kind === 'Appointment'
                          }">
                            {{ e.kind }}
                          </span>
                          <span v-if="e.status" class="text-xs px-1.5 sm:px-2 py-0.5 sm:py-1 rounded-full" :class="{
                            'bg-yellow-100 text-yellow-700': e.status === 'pending',
                            'bg-green-100 text-green-700': e.status === 'completed',
                            'bg-blue-100 text-blue-700': e.status === 'approved',
                            'bg-red-100 text-red-700': e.status === 'rejected' || e.status === 'cancelled'
                          }">
                            {{ e.status.charAt(0).toUpperCase() + e.status.slice(1) }}
                          </span>
                          <!-- Completion Notes Indicator -->
                          <span v-if="e.status === 'completed' && e.completionData" class="text-xs px-1.5 sm:px-2 py-0.5 sm:py-1 rounded-full bg-emerald-100 text-emerald-700 border border-emerald-200">
                            📝 Notes
                          </span>
                        </div>
                        <div class="text-xs text-gray-400">{{ formatDate(e.date, 'PPpp') }}</div>
                      </div>
                      
                      <h4 class="text-sm sm:text-base font-medium text-gray-900 mb-1">{{ e.title }}</h4>
                      <div v-if="e.subtitle" class="text-xs sm:text-sm text-gray-600 mb-2">{{ e.subtitle }}</div>
                      <div v-if="e.details" class="text-xs sm:text-sm text-gray-500 bg-gray-50 rounded p-2">{{ e.details }}</div>
                      
                      <!-- Completion Summary for Completed Appointments -->
                      <div v-if="e.status === 'completed' && e.completionData" class="mt-2 sm:mt-3 pt-2 sm:pt-3 border-t border-gray-100">
                        <div class="flex items-center gap-1 sm:gap-2 mb-2 sm:mb-3">
                          <div class="w-1.5 h-1.5 sm:w-2 sm:h-2 rounded-full bg-green-500"></div>
                          <span class="text-xs sm:text-sm font-medium text-gray-700">Completion Summary</span>
                        </div>
                        
                        <!-- Services Summary -->
                        <div v-if="e.completionData.services && e.completionData.services.length > 0" class="mb-2 sm:mb-3">
                          <div class="text-xs font-medium text-gray-600 mb-1 sm:mb-2">Services Completed:</div>
                          <div class="space-y-1 sm:space-y-2">
                            <div v-for="(service, index) in e.completionData.services" :key="index" class="bg-blue-50 rounded-lg p-2 sm:p-3 border border-blue-100">
                              <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-1 sm:gap-0 mb-1 sm:mb-2">
                                <span class="text-xs sm:text-sm font-medium text-blue-800">{{ service.name || `Service ${index + 1}` }}</span>
                                <span class="text-xs text-blue-600 capitalize">{{ service.status?.replace('_', ' ') || 'completed' }}</span>
                              </div>
                              <div v-if="service.duration" class="text-xs text-blue-600 mb-1">Duration: {{ service.duration }} minutes</div>
                              <div v-if="service.notes" class="text-xs sm:text-sm text-blue-700 bg-white rounded p-1.5 sm:p-2 border border-blue-200">
                                {{ service.notes }}
                              </div>
                            </div>
                          </div>
                        </div>
                        
                        <!-- Pet Health Assessment -->
                        <div v-if="e.completionData.pets && e.completionData.pets.length > 0" class="mb-2 sm:mb-3">
                          <div class="text-xs font-medium text-gray-600 mb-1 sm:mb-2">Health Assessment:</div>
                          <div class="space-y-1 sm:space-y-2">
                            <div v-for="(pet, index) in e.completionData.pets" :key="index" class="bg-green-50 rounded-lg p-2 sm:p-3 border border-green-100">
                              <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-1 sm:gap-0 mb-1 sm:mb-2">
                                <span class="text-xs sm:text-sm font-medium text-green-800">{{ pet.name || `Pet ${index + 1}` }}</span>
                                <span class="text-xs text-green-600 capitalize">{{ pet.overallHealth || 'assessed' }}</span>
                              </div>
                              <div v-if="pet.weight" class="text-xs text-green-600 mb-1">Weight: {{ pet.weight }} kg</div>
                              <div v-if="pet.healthNotes" class="text-xs sm:text-sm text-green-700 bg-white rounded p-1.5 sm:p-2 border border-green-200">
                                {{ pet.healthNotes }}
                              </div>
                              <div v-if="pet.followUpRequired" class="mt-1 sm:mt-2">
                                <div class="flex items-center gap-1 sm:gap-2">
                                  <span class="text-xs font-medium text-orange-600">Follow-up Required:</span>
                                  <span class="text-xs text-orange-600 bg-orange-100 px-1.5 sm:px-2 py-0.5 sm:py-1 rounded-full">Yes</span>
                                </div>
                                <div v-if="pet.followUpNotes" class="text-xs sm:text-sm text-orange-700 bg-orange-50 rounded p-1.5 sm:p-2 mt-1 border border-orange-200">
                                  {{ pet.followUpNotes }}
                                </div>
                              </div>
                            </div>
                          </div>
                        </div>
                        
                        <!-- General Notes -->
                        <div v-if="e.completionData.generalNotes" class="space-y-2 sm:space-y-3">
                          <div v-if="e.completionData.generalNotes.treatmentSummary" class="bg-purple-50 rounded-lg p-2 sm:p-3 border border-purple-100">
                            <div class="text-xs font-medium text-purple-800 mb-1">Treatment Summary:</div>
                            <div class="text-xs sm:text-sm text-purple-700">{{ e.completionData.generalNotes.treatmentSummary }}</div>
                          </div>
                          
                          <div v-if="e.completionData.generalNotes.ownerInstructions" class="bg-indigo-50 rounded-lg p-2 sm:p-3 border border-indigo-100">
                            <div class="text-xs font-medium text-indigo-800 mb-1">Owner Instructions:</div>
                            <div class="text-xs sm:text-sm text-indigo-700">{{ e.completionData.generalNotes.ownerInstructions }}</div>
                          </div>
                          
                          <div v-if="e.completionData.generalNotes.nextSteps" class="bg-amber-50 rounded-lg p-2 sm:p-3 border border-amber-100">
                            <div class="text-xs font-medium text-amber-800 mb-1">Next Steps:</div>
                            <div class="text-xs sm:text-sm text-amber-700">{{ e.completionData.generalNotes.nextSteps }}</div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Hidden file input for pet photo -->
    <input type="file" ref="photoInput" @change="handlePetPhotoSelect" accept="image/*" class="hidden" />

    <!-- Vaccination Card Modal -->
    <div v-if="showVaccinationCardModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-2 sm:p-4" @click="showVaccinationCardModal = false">
      <div class="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[85vh] overflow-y-auto" @click.stop>
        <!-- Modal Header -->
        <div class="print-header bg-gradient-to-r from-blue-600 to-blue-700 text-white p-3 sm:p-4 rounded-t-lg">
          <div class="flex items-center gap-2 sm:gap-3">
            <svg class="w-5 h-5 sm:w-6 sm:h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            <h2 class="text-base sm:text-lg font-bold">Vaccination Card</h2>
          </div>
          <p class="text-blue-100 mt-1 text-xs sm:text-sm">Official Pet Health Record</p>
        </div>

        <!-- Modal Content -->
        <div id="vaccination-card-content" class="p-3 sm:p-4">
          <!-- Pet Information Section -->
          <div class="pet-info bg-gray-50 rounded-lg p-3 sm:p-4 mb-3 sm:mb-4 border border-gray-200">
            <div class="flex flex-col sm:flex-row items-start gap-3 sm:gap-4">
              <div class="flex items-center gap-2 sm:gap-3">
                <img 
                  :src="selectedLocalPet?.photoURL || defaultPetPhotoURL" 
                  :alt="selectedLocalPet?.name"
                  class="w-12 h-12 sm:w-16 sm:h-16 rounded-full object-cover border-2 border-gray-200"
                >
                <div>
                  <h3 class="text-base sm:text-lg font-bold text-gray-900 break-words">{{ selectedLocalPet?.name }}</h3>
                  <p class="text-xs sm:text-sm text-gray-600 break-words">{{ selectedLocalPet?.species }} • {{ selectedLocalPet?.breed }}</p>
                  <p class="text-xs text-gray-500 break-words">{{ selectedLocalPet?.ageYears }}y {{ selectedLocalPet?.ageMonths }}m • {{ selectedLocalPet?.gender }}</p>
                </div>
              </div>
              
              <div class="flex-1 space-y-1 sm:space-y-2 text-xs sm:text-sm">
                <div class="flex justify-between">
                  <span class="text-gray-500">Owner:</span>
                  <span class="font-medium">{{ authStore.user?.firstName }} {{ authStore.user?.lastName }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-gray-500">Contact:</span>
                  <span class="font-medium">{{ authStore.user?.phone || authStore.user?.email || 'N/A' }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-gray-500">Generated:</span>
                  <span class="font-medium">{{ formatDate(new Date(), 'MMM dd, yyyy') }}</span>
                </div>
              </div>
            </div>
          </div>
          
          <!-- Vaccination Records Section -->
          <div v-if="vaccinationRecords.length > 0" class="space-y-2 sm:space-y-3">
            <h4 class="text-base sm:text-lg font-semibold text-gray-900 mb-2 sm:mb-3">Vaccination History</h4>
            
            <div class="space-y-3 sm:space-y-4">
              <div 
                v-for="(record, index) in sortedVaccinationRecords" 
                :key="record.id || index"
                class="vaccination-record border border-gray-200 rounded-lg p-3 sm:p-4 hover:shadow-md transition-shadow"
              >
                <div class="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-2 sm:gap-0 mb-2 sm:mb-3">
                  <div>
                    <h5 class="text-sm sm:text-base font-medium text-gray-900 break-words">{{ record.vaccineName || 'Vaccination' }}</h5>
                    <p class="text-xs sm:text-sm text-gray-500 break-words">{{ record.vaccineType || 'Standard vaccine' }}</p>
                  </div>
                  <div class="text-left sm:text-right">
                    <div class="text-xs sm:text-sm text-gray-500">Date Administered</div>
                    <div class="text-sm sm:text-base font-medium text-gray-900">{{ formatDate(record.date, 'MMM dd, yyyy') }}</div>
                  </div>
                </div>
                
                <div class="text-xs sm:text-sm">
                  <div>
                    <span class="text-gray-500">Processing Time:</span>
                    <span class="ml-2 font-medium">{{ record.processingTime || 'N/A' }}</span>
                  </div>
                </div>
                
                <div v-if="record.notes" class="mt-2 sm:mt-3 pt-2 sm:pt-3 border-t border-gray-100">
                  <span class="text-xs sm:text-sm text-gray-500">Notes:</span>
                  <span class="ml-2 text-xs sm:text-sm text-gray-900 break-words">{{ record.notes }}</span>
                </div>
                
                <div class="mt-2 sm:mt-3 pt-2 sm:pt-3 border-t border-gray-100">
                  <div class="flex items-center justify-between">
                    <span class="text-xs sm:text-sm text-gray-500">Administered by:</span>
                    <span class="text-xs sm:text-sm font-medium">{{ record.administeredBy || 'Veterinarian' }}</span>
                  </div>
                  <div class="flex items-center justify-between mt-1">
                    <span class="text-xs sm:text-sm text-gray-500">Location:</span>
                    <span class="text-xs sm:text-sm font-medium">{{ record.location || 'ProVet Clinic' }}</span>
                  </div>
                  <div class="flex items-center justify-between mt-1">
                    <span class="text-xs sm:text-sm text-gray-500">Appointment ID:</span>
                    <span class="text-xs sm:text-sm font-medium text-gray-600">{{ record.appointmentId || 'N/A' }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- No Vaccination Records -->
          <div v-else class="text-center py-8 sm:py-12">
            <div class="w-12 h-12 sm:w-16 sm:h-16 rounded-full bg-gray-100 flex items-center justify-center mb-3 sm:mb-4 mx-auto">
              <svg class="w-6 h-6 sm:w-8 sm:h-8 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
            </div>
            <h4 class="text-base sm:text-lg font-medium text-gray-900 mb-1 sm:mb-2">No Vaccination Records</h4>
            <p class="text-sm sm:text-base text-gray-500 mb-4 sm:mb-6 px-4">{{ selectedLocalPet?.name }} doesn't have any vaccination records yet.</p>
          </div>

          <!-- Action Buttons -->
          <div class="mt-6 pt-4 border-t border-gray-200 flex flex-row gap-1.5 sm:gap-4">
            <button 
              @click="printVaccinationCard"
              class="flex-1 px-1.5 sm:px-3 py-1 sm:py-2 rounded-full bg-purple-500 text-white hover:bg-purple-700 transition-colors flex items-center justify-center gap-1 sm:gap-2 text-xs sm:text-sm"
            >
              <svg class="w-3 h-3 sm:w-4 sm:h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"></path>
              </svg>
              <span class="hidden xs:inline">Print Card</span>
              <span class="xs:hidden">Print</span>
            </button>
            <button 
              @click="downloadVaccinationCard"
              :disabled="isGeneratingPDF"
              :class="[
                'flex-1 px-1.5 sm:px-3 py-1 sm:py-2 rounded-full transition-colors flex items-center justify-center gap-1 sm:gap-2 text-xs sm:text-sm',
                isGeneratingPDF 
                  ? 'bg-gray-400 cursor-not-allowed' 
                  : 'bg-blue-500 text-white hover:bg-blue-700'
              ]"
            >
              <svg v-if="isGeneratingPDF" class="w-3 h-3 sm:w-4 sm:h-4 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
              </svg>
              <svg v-else class="w-3 h-3 sm:w-4 sm:h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
              <span class="hidden xs:inline">{{ isGeneratingPDF ? 'Generating PDF...' : 'Download PDF' }}</span>
              <span class="xs:hidden">{{ isGeneratingPDF ? 'Generating...' : 'Download' }}</span>
            </button>
            <button 
              @click="showVaccinationCardModal = false"
              class="flex-1 px-1.5 sm:px-3 py-1 sm:py-2 rounded-full bg-red-200 text-red-800 hover:bg-red-300 transition-colors text-xs sm:text-sm"
            >
              Close
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Overlay loader -->
    <LoadingSpinner v-if="isSavingChanges || isDeleting" isOverlay :text="loadingText" />

    <!-- Success Modal -->
    <div v-if="showSuccessModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4" @click.self="showSuccessModal = false">
      <div class="bg-white rounded-xl shadow-xl max-w-sm w-full mx-auto p-6" @click.stop>
        <div class="flex items-center justify-center w-12 h-12 rounded-full bg-green-100 mx-auto mb-4">
          <CheckCircleIcon class="h-6 w-6 text-green-600" />
        </div>
        <h3 class="text-lg font-medium text-center text-gray-900 mb-2">Success</h3>
        <p class="text-sm text-gray-500 text-center mb-6">
          {{ statusMessage }}
        </p>
        <div class="flex justify-center">
          <button 
            @click="showSuccessModal = false"
            class="px-3 py-1.5 sm:px-4 sm:py-2 border border-transparent rounded-full shadow-sm text-xs sm:text-sm font-medium text-white bg-green-600 hover:bg-green-700"
          >
            OK
          </button>
        </div>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="showDeleteModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4" @click.self="showDeleteModal = false">
      <div class="bg-white rounded-xl shadow-xl max-w-sm w-full mx-auto p-6" @click.stop>
        <div class="flex items-center justify-center w-12 h-12 rounded-full bg-red-100 mx-auto mb-4">
          <Trash2 class="h-6 w-6 text-red-600" />
        </div>
        <h3 class="text-lg font-medium text-center text-gray-900 mb-2">Delete Pet</h3>
        <p class="text-sm text-gray-500 text-center mb-6">
          Are you sure you want to delete <strong>{{ petToDelete?.name }}</strong>? This action cannot be undone.
        </p>
        <div class="flex justify-center gap-3">
          <button 
            @click="showDeleteModal = false"
            class="px-3 py-1.5 sm:px-4 sm:py-2 border border-gray-300 rounded-full shadow-sm text-xs sm:text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
          >
            Cancel
          </button>
          <button 
            @click="deletePet"
            :disabled="isDeleting"
            class="px-3 py-1.5 sm:px-4 sm:py-2 border border-transparent rounded-full shadow-sm text-xs sm:text-sm font-medium text-white bg-red-600 hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ isDeleting ? 'Deleting...' : 'Delete' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Error Modal -->
    <div v-if="showErrorModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4" @click.self="showErrorModal = false">
      <div class="bg-white rounded-xl shadow-xl max-w-sm w-full mx-auto p-6" @click.stop>
        <div class="flex items-center justify-center w-12 h-12 rounded-full bg-red-100 mx-auto mb-4">
          <XCircleIcon class="h-6 w-6 text-red-600" />
        </div>
        <h3 class="text-lg font-medium text-center text-gray-900 mb-2">Error</h3>
        <p class="text-sm text-gray-500 text-center mb-6">
          {{ errorMessage }}
        </p>
        <div class="flex justify-center">
          <button 
            @click="showErrorModal = false"
            class="px-3 py-1.5 sm:px-4 sm:py-2 border border-transparent rounded-full shadow-sm text-xs sm:text-sm font-medium text-white bg-red-600 hover:bg-red-700"
          >
            OK
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
  
<script setup>
  import { ref, computed, onMounted, onBeforeUnmount, watch, nextTick } from 'vue';
import { useRoute } from 'vue-router';
  import { 
  Camera as CameraIcon,
  Plus as PlusIcon,
  PlusCircle,
  FileText as FileTextIcon,
  Activity as ActivityIcon,
  Folder as FolderIcon,
  Trash2,
  Eye as EyeIcon,
  Edit as EditIcon,
  ArrowLeft as ArrowLeftIcon,
  ChevronDown as ChevronDownIcon,
  X as XIcon,
  Shield as ShieldIcon,
  Heart as HeartIcon,
  Syringe as SyringeIcon,
  CheckCircle as CheckCircleIcon,
  XCircle as XCircleIcon,
} from 'lucide-vue-next';
import { usePetsStore } from '@/stores/modules/petsStore';
import { useAuthStore } from '@/stores/modules/authStore';
import { useArchivesStore } from '@/stores/modules/archivesStore';
import { useAppointmentStore } from '@/stores/modules/appointmentStore';
import { format } from 'date-fns';
import LoadingSpinner from '@/components/common/LoadingSpinner.vue';



// Stores
const petsStore = usePetsStore();
const authStore = useAuthStore();
const archivesStore = useArchivesStore();
const appointmentStore = useAppointmentStore();

// Emit events
const emit = defineEmits(['pet-added', 'pet-updated', 'pet-deleted', 'pets-changed']);

// Route handling
const route = useRoute();

// State
const selectedPetId = ref(null);
const selectedPetTab = ref('basic-details');
const photoInput = ref(null);
const editablePet = ref({});
const showDeleteModal = ref(false);
const isLoading = ref(false);
const initialLoading = ref(true);
const isSavingChanges = ref(false);
const isDeleting = ref(false);
const localPets = ref([]);
const pendingChanges = ref(false);
const deletedPetIds = ref([]);
const petToDelete = ref(null);
const viewMode = ref('view');
const originalPets = ref([]);
const genderDropdownOpen = ref(false);
const showVaccinationCardModal = ref(false);
const vaccinationRecords = ref([]);
const isGeneratingPDF = ref(false);

// Initialize state based on route parameters immediately
if (route.query.addPet === 'true') {
  // Set state immediately to prevent showing pet cards list
  // This should behave exactly like the addNewPet() function
  const tempId = `temp-${Date.now()}`;
  const newPet = { tempId, name: 'New Pet', species: '', breed: '', ageYears: 0, ageMonths: 0, ageWeeks: 0, weight: 0, gender: '', photoURL: '', isNew: true };
  localPets.value.push(newPet);
  pendingChanges.value = true; // This is important for the button state
  selectedPetId.value = tempId;
  editablePet.value = { ...newPet };
  viewMode.value = 'edit';
  // Make sure originalPets is initialized to prevent issues
  originalPets.value = [];
} else if (route.query.petId) {
  selectedPetId.value = route.query.petId;
  selectedPetTab.value = 'basic-details';
  viewMode.value = 'view';
  // Only show loading if we don't have the pet data yet
  // This will be handled in onMounted after pets are loaded
}

// Success/Error message states
const showSuccessModal = ref(false);
const showErrorModal = ref(false);
const statusMessage = ref('');
const errorMessage = ref('');

// History state
const historyLoading = ref(false);
const historyError = ref('');
const petAppointments = ref([]);
const historyFilter = ref('all');
const servicesCache = ref(new Map()); // Cache for service details
const categories = ref([]); // Available categories from categories collection
const categoryServiceIds = ref(new Map()); // Map of categoryId to service IDs

// Default pet photo URL with white background (same as Dashboard.vue)
const defaultPetPhotoURL = 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"%3E%3Crect width="24" height="24" fill="white"/%3E%3Cg fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"%3E%3Ccircle cx="11" cy="4" r="2"/%3E%3Ccircle cx="18" cy="8" r="2"/%3E%3Ccircle cx="20" cy="16" r="2"/%3E%3Cpath d="M9 10a5 5 0 0 1 5 5v3.5a3.5 3.5 0 0 1-6.84 1.045q-.64-2.065-2.7-2.705A3.5 3.5 0 0 1 5.5 10Z"/%3E%3C/g%3E%3C/svg%3E'

// Loading text
const loadingText = computed(() => {
  if (isDeleting.value) return 'Deleting pet...';
  if (isSavingChanges.value) return 'Saving changes...';
  return 'Loading pets data...';
});

// Gender options
const genderOptions = [
  { value: 'male', label: 'Male' },
  { value: 'female', label: 'Female' }
];

// Tabs
const petTabs = [
  { id: 'basic-details', name: 'Basic Details', icon: FileTextIcon },
  { id: 'medical-history', name: 'Medical History', icon: ActivityIcon },
];

// Debug: Log tabs on mount
console.log('Pet tabs defined:', petTabs);


// Handle tab clicks for desktop navigation
const handleTabClick = (tabId) => {
  console.log('Tab clicked:', tabId);
  console.log('Current selected pet:', selectedLocalPet.value);
  console.log('Current user:', authStore.user);
  
  selectedPetTab.value = tabId;
  
  // If medical history tab is selected, fetch appointments
  if (tabId === 'medical-history') {
    console.log('Medical history tab clicked');
    if (selectedLocalPet.value) {
      console.log('Pet found, fetching appointments');
      fetchPetAppointments();
    } else {
      console.log('No pet selected, cannot fetch appointments');
    }
  }
};


const toggleGenderDropdown = () => {
  genderDropdownOpen.value = !genderDropdownOpen.value;
};

const selectGender = (gender) => {
  editablePet.value.gender = gender;
  genderDropdownOpen.value = false;
  updateLocalPet();
};

const formatGender = (gender) => {
  return gender === 'male' ? 'Male' : gender === 'female' ? 'Female' : gender;
};

// Computed
const storedPets = computed(() => petsStore.getPets);
const selectedLocalPet = computed(() => {
  if (!selectedPetId.value) return null;
  const pet = localPets.value.find(p => (p.id || p.tempId) === selectedPetId.value) || null;
  console.log('Selected local pet computed:', {
    selectedPetId: selectedPetId.value,
    petFound: !!pet,
    petData: pet,
    medicalHistory: pet?.medicalHistory,
    vaccinations: pet?.vaccinations
  });
  return pet;
});
const hasUnsavedNewPet = computed(() => localPets.value.some(p => p.isNew === true));

// Fetch pets
const fetchPets = async () => {
  if (authStore.user && authStore.user.userId) {
    isLoading.value = true;
    initialLoading.value = true;
    await petsStore.fetchUserPets(authStore.user.userId);
    const userPets = storedPets.value;
    
    console.log('Fetched pets from store:', userPets);
    console.log('Sample pet medical history:', userPets[0]?.medicalHistory);
    console.log('Sample pet vaccinations:', userPets[0]?.vaccinations);
    
    const petsChanged = JSON.stringify(userPets) !== JSON.stringify(localPets.value);
    
    // Preserve any existing new pets (with isNew: true) when fetching from store
    const existingNewPets = localPets.value.filter(p => p.isNew === true);
    localPets.value = userPets.map(p => ({ ...p }));
    
    // Add back any existing new pets
    existingNewPets.forEach(newPet => {
      localPets.value.push(newPet);
    });
    
    originalPets.value = JSON.parse(JSON.stringify(localPets.value));
    
    // Clear records cache when pets are refreshed
    petRecordsCache.value.clear();
    
    isLoading.value = false;
    initialLoading.value = false;
    pendingChanges.value = false;
    deletedPetIds.value = [];
    if (petsChanged) emit('pets-changed', localPets.value);
  }
};

// Helpers
const formatPetAge = (pet) => {
  const ageParts = [];
  
  if (pet.ageYears && pet.ageYears > 0) {
    ageParts.push(`${pet.ageYears} year${pet.ageYears > 1 ? 's' : ''}`);
  }
  
  if (pet.ageMonths && pet.ageMonths > 0) {
    ageParts.push(`${pet.ageMonths} month${pet.ageMonths > 1 ? 's' : ''}`);
  }
  
  if (pet.ageWeeks && pet.ageWeeks > 0) {
    ageParts.push(`${pet.ageWeeks} week${pet.ageWeeks > 1 ? 's' : ''}`);
  }
  
  return ageParts.length > 0 ? ageParts.join(', ') : 'Age not specified';
};

const getDisplayName = () => {
  return selectedLocalPet.value?.name || 'Unnamed Pet';
};

const getSavedPetName = () => {
  const pet = selectedLocalPet.value;
  if (!pet) return 'Unnamed Pet';
  
  // For new pets, show the editable name
  if (pet.isNew) {
    return editablePet.value.name || 'New Pet';
  }
  
  // For existing pets, get the original name from the store (not the modified local data)
  const originalPet = storedPets.value.find(p => p.id === pet.id);
  return originalPet?.name || 'Unnamed Pet';
};

const getDisplayDetails = () => {
  const pet = selectedLocalPet.value;
  if (!pet) return '';
  
  const details = [];
  if (pet.species) details.push(pet.species);
  if (pet.breed) details.push(pet.breed);
  if (pet.ageYears || pet.ageMonths || pet.ageWeeks) details.push(formatPetAge(pet));
  
  return details.length > 0 ? details.join(' • ') : 'No details available';
};

const getSavedPetDetails = () => {
  const pet = selectedLocalPet.value;
  if (!pet) return '';
  
  // For new pets, show the editable data
  if (pet.isNew) {
    const details = [];
    if (editablePet.value.species) details.push(editablePet.value.species);
    if (editablePet.value.breed) details.push(editablePet.value.breed);
    if (editablePet.value.ageYears || editablePet.value.ageMonths || editablePet.value.ageWeeks) {
      details.push(formatPetAge(editablePet.value));
    }
    return details.length > 0 ? details.join(' • ') : 'No details available';
  }
  
  // For existing pets, get the original data from the store (not the modified local data)
  const originalPet = storedPets.value.find(p => p.id === pet.id);
  if (!originalPet) return 'No details available';
  
  const details = [];
  if (originalPet.species) details.push(originalPet.species);
  if (originalPet.breed) details.push(originalPet.breed);
  if (originalPet.ageYears || originalPet.ageMonths || originalPet.ageWeeks) {
    details.push(formatPetAge(originalPet));
  }
  
  return details.length > 0 ? details.join(' • ') : 'No details available';
};

// Cache for pet records count to avoid repeated API calls
const petRecordsCache = ref(new Map());

// Function to calculate total records for a pet
const getPetRecordsCount = (pet) => {
  if (!pet || pet.isNew) return 0;
  
  // Check cache first
  if (petRecordsCache.value.has(pet.id)) {
    return petRecordsCache.value.get(pet.id);
  }
  
  let totalRecords = 0;
  
  // Count direct medical history records
  if (pet.medicalHistory && Array.isArray(pet.medicalHistory)) {
    totalRecords += pet.medicalHistory.length;
  }
  
  // Count direct vaccination records
  if (pet.vaccinations && Array.isArray(pet.vaccinations)) {
    totalRecords += pet.vaccinations.length;
  }
  
  // Always fetch from appointments to get the complete count
  // This ensures we get the most accurate count including appointment-based records
  fetchPetRecordsCount(pet.id);
  
  // If we have direct records, return them immediately while fetching appointments
  if (totalRecords > 0) {
    return totalRecords;
  }
  
  // Return a loading indicator while fetching
  return '...';
};

// Function to fetch actual records count from appointments
const fetchPetRecordsCount = async (petId) => {
  try {
    if (!authStore.user?.userId) return;
    
    console.log('Fetching records count for pet:', petId);
    
    // Fetch appointments for this pet
    const userAppointments = await appointmentStore.fetchAppointmentsByUserId(authStore.user.userId);
    const petAppointments = (userAppointments || []).filter(a => 
      a && ((a.petId && a.petId === petId) || (Array.isArray(a.petIds) && a.petIds.includes(petId)))
    );
    
    console.log('Pet appointments found:', petAppointments.length);
    
    // Count all appointments (not just completed ones) as they represent medical records
    // This matches the logic used in the medical history tab
    let totalRecords = petAppointments.length;
    
    // Also check for direct medical history and vaccinations in the pet data
    const pet = localPets.value.find(p => p.id === petId);
    if (pet) {
      if (pet.medicalHistory && Array.isArray(pet.medicalHistory)) {
        totalRecords += pet.medicalHistory.length;
      }
      if (pet.vaccinations && Array.isArray(pet.vaccinations)) {
        totalRecords += pet.vaccinations.length;
      }
    }
    
    console.log('Total records count for pet', petId, ':', totalRecords);
    
    // Cache the result
    petRecordsCache.value.set(petId, totalRecords);
    
    // Force reactivity update
    const petIndex = localPets.value.findIndex(p => p.id === petId);
    if (petIndex !== -1) {
      // Trigger reactivity by updating the local pets array
      localPets.value = [...localPets.value];
    }
    
  } catch (error) {
    console.error('Error fetching pet records count:', error);
    // Cache 0 as fallback
    petRecordsCache.value.set(petId, 0);
  }
};

const formatPetDetails = (pet) => {
  if (!pet) return '';
  const breed = pet.breed ? pet.breed : 'Breed not specified';
  const age = formatPetAge(pet);
  return [breed, age].filter(Boolean).join(' • ');
};

// Bento helpers
const getBentoCardClasses = (index) => '';
const getBentoAccent = (index) => {
  const accents = [
    'bg-gradient-to-br from-blue-50 to-cyan-50',
    'bg-gradient-to-br from-purple-50 to-pink-50',
    'bg-gradient-to-br from-emerald-50 to-teal-50',
    'bg-gradient-to-br from-amber-50 to-orange-50',
    'bg-gradient-to-br from-slate-50 to-gray-50'
  ];
  return accents[index % accents.length];
};


// Local updates
const updateLocalPet = () => {
  if (!selectedPetId.value) return;
  const idx = localPets.value.findIndex(p => (p.id || p.tempId) === selectedPetId.value);
  if (idx !== -1) {
    localPets.value[idx] = { ...localPets.value[idx], ...editablePet.value, changed: true };
    pendingChanges.value = true;
  }
};

// Actions
const viewPet = (pet) => {
  console.log('Viewing pet:', pet);
  selectedPetId.value = pet.id || pet.tempId;
  selectedPetTab.value = 'basic-details';
  viewMode.value = 'view';
  genderDropdownOpen.value = false;
  
  // Wait for next tick to ensure selectedLocalPet is updated
  nextTick(() => {
    console.log('Selected pet data (after nextTick):', selectedLocalPet.value);
    console.log('Pet medical history:', selectedLocalPet.value?.medicalHistory);
    console.log('Pet vaccinations:', selectedLocalPet.value?.vaccinations);
    console.log('Selected pet ID:', selectedPetId.value);
    console.log('Selected pet tab:', selectedPetTab.value);
  });
  
  if (selectedLocalPet.value) editablePet.value = { ...selectedLocalPet.value };
};

const editPet = (pet) => {
  selectedPetId.value = pet.id || pet.tempId;
  viewMode.value = 'edit';
  genderDropdownOpen.value = false;
  if (selectedLocalPet.value) editablePet.value = { ...selectedLocalPet.value };
};

const addNewPet = () => {
  if (hasUnsavedNewPet.value) return;
  const tempId = `temp-${Date.now()}`;
  const newPet = { tempId, name: 'New Pet', species: '', breed: '', ageYears: 0, ageMonths: 0, ageWeeks: 0, weight: 0, gender: '', photoURL: '', isNew: true };
  localPets.value.push(newPet);
  pendingChanges.value = true;
  selectedPetId.value = tempId;
  editablePet.value = { ...newPet };
  viewMode.value = 'edit';
};

const backToList = () => {
  if (selectedLocalPet.value && selectedLocalPet.value.isNew) {
    localPets.value = localPets.value.filter(p => (p.id || p.tempId) !== selectedLocalPet.value.tempId);
    pendingChanges.value = true;
  } else if (selectedLocalPet.value && selectedLocalPet.value.changed) {
    const original = originalPets.value.find(p => p.id === selectedLocalPet.value.id);
    if (original) {
      const index = localPets.value.findIndex(p => p.id === selectedLocalPet.value.id);
      if (index !== -1) {
        localPets.value[index] = { ...original };
        delete localPets.value[index].changed;
      }
    }
  }
  selectedPetId.value = null;
  viewMode.value = 'edit';
  genderDropdownOpen.value = false;
};

const cancelChanges = () => {
  if (selectedLocalPet.value && selectedLocalPet.value.isNew) {
    // Remove the new pet from the list
    localPets.value = localPets.value.filter(p => (p.id || p.tempId) !== selectedLocalPet.value.tempId);
    pendingChanges.value = localPets.value.some(p => p.changed || p.isNew);
  } else if (selectedLocalPet.value && selectedLocalPet.value.changed) {
    // Revert changes to the original state
    const original = originalPets.value.find(p => p.id === selectedLocalPet.value.id);
    if (original) {
      const index = localPets.value.findIndex(p => p.id === selectedLocalPet.value.id);
      if (index !== -1) {
        localPets.value[index] = { ...original };
        delete localPets.value[index].changed;
      }
    }
    pendingChanges.value = localPets.value.some(p => p.changed || p.isNew);
  }
  
  // Reset to list view
  selectedPetId.value = null;
  viewMode.value = 'view';
  genderDropdownOpen.value = false;
};

const confirmDeletePet = (pet) => { petToDelete.value = pet; showDeleteModal.value = true; };
const deletePet = async () => {
  if (!petToDelete.value) return;
  try {
    isDeleting.value = true;
    console.log('Deleting pet:', petToDelete.value);
    console.log('User ID:', authStore.user.userId);
    
    if (petToDelete.value.id) {
      const success = await petsStore.deletePet(authStore.user.userId, petToDelete.value.id);
      console.log('Delete result:', success);
      
      if (success) {
        // Remove from local list
        localPets.value = localPets.value.filter(p => (p.id || p.tempId) !== (petToDelete.value.id || petToDelete.value.tempId));
        pendingChanges.value = true;
        
        // Clear selection if this pet was selected
        if (selectedPetId.value === (petToDelete.value.id || petToDelete.value.tempId)) {
          selectedPetId.value = null;
        }
        
        // Show success message
        statusMessage.value = `Pet "${petToDelete.value.name}" has been deleted successfully`;
        showSuccessModal.value = true;
        
        // Refresh pets data
        await fetchPets();
      } else {
        throw new Error('Failed to delete pet');
      }
    } else {
      // Handle temp pets (not yet saved)
      localPets.value = localPets.value.filter(p => (p.id || p.tempId) !== (petToDelete.value.id || petToDelete.value.tempId));
      pendingChanges.value = true;
      
      if (selectedPetId.value === (petToDelete.value.id || petToDelete.value.tempId)) {
        selectedPetId.value = null;
      }
    }
    
    showDeleteModal.value = false;
    petToDelete.value = null;
  } catch (e) {
    console.error('Error deleting pet:', e);
    errorMessage.value = e.message || 'Failed to delete pet. Please try again.';
    showErrorModal.value = true;
  } finally {
    isDeleting.value = false;
  }
};

const triggerPetPhotoUpload = () => { photoInput.value?.click(); };
const handlePetPhotoSelect = async (event) => {
  const file = event.target.files[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = (e) => { if (selectedLocalPet.value) { editablePet.value.photoFile = file; editablePet.value.photoURL = e.target.result; updateLocalPet(); } };
  reader.readAsDataURL(file);
};

// History filter method
const setHistoryFilter = (filter) => {
  historyFilter.value = filter;
};

// Cache for categories and services
const categoriesCache = ref(null);
const categoriesLastFetch = ref(0);
const CATEGORIES_CACHE_EXPIRY = 10 * 60 * 1000; // 10 minutes

// Function to populate categories and their services from the collections with caching
const populateCategoriesAndServices = async () => {
  const now = Date.now();
  
  // Check if we have valid cached data
  if (categoriesCache.value && (now - categoriesLastFetch.value < CATEGORIES_CACHE_EXPIRY)) {
    console.log('Using cached categories and services');
    categories.value = categoriesCache.value;
    return;
  }
  
  try {
    console.log('Fetching fresh categories and services...');
    const { collection, query, where, getDocs } = await import('firebase/firestore');
    const { db } = await import('@shared/firebase');
    
    // First, fetch all categories
    const categoriesQuery = query(
      collection(db, 'categories'),
      where('archived', '==', false) // Only non-archived categories
    );
    
    const categoriesSnapshot = await getDocs(categoriesQuery);
    const categoriesData = [];
    
    // For each category, fetch its services
    for (const categoryDoc of categoriesSnapshot.docs) {
      const categoryData = categoryDoc.data();
      const categoryId = categoryDoc.id;
      
      // Fetch services for this category
      const servicesQuery = query(
        collection(db, 'services'),
        where('categoryId', '==', categoryId)
      );
      
      const servicesSnapshot = await getDocs(servicesQuery);
      const serviceIds = [];
      
      servicesSnapshot.forEach((serviceDoc) => {
        const serviceData = serviceDoc.data();
        serviceIds.push(serviceDoc.id);
        // Cache the service data
        servicesCache.value.set(serviceDoc.id, serviceData);
      });
      
      // Store category and its services
      categoriesData.push({
        id: categoryId,
        name: categoryData.name,
        description: categoryData.description,
        coverPhoto: categoryData.coverPhoto,
        serviceIds: serviceIds
      });
      
      // Map category to service IDs
      categoryServiceIds.value.set(categoryId, serviceIds);
    }
    
    // Cache the results
    categoriesCache.value = categoriesData;
    categoriesLastFetch.value = now;
    
    // Update the reactive categories
    categories.value = categoriesData;
    
    console.log('Populated categories and services:', categoriesData.length);
    console.log('Category service mapping:', Object.fromEntries(categoryServiceIds.value));
    
  } catch (error) {
    console.error('Error fetching categories and services:', error);
    // Fallback to basic categories
    categories.value = [
      { id: 'telehealth5192', name: 'Telehealth', description: 'Remote consultations and services', serviceIds: ['video9437'] },
      { id: 'elective3401', name: 'Elective Veterinary Services', description: 'Preventive Care Planned procedures and care', serviceIds: [] },
      { id: 'veterinary8515', name: 'Veterinary Services', description: 'General veterinary care', serviceIds: [] },
      { id: 'walk-in8438', name: 'Walk-in Services', description: 'Immediate care services', serviceIds: [] }
    ];
  }
};

// Helper function to check if a service is telehealth based on categoryId
const isServiceTelehealth = async (serviceId) => {
  if (!serviceId) return false;
  
  // Check cache first
  if (servicesCache.value.has(serviceId)) {
    const service = servicesCache.value.get(serviceId);
    return service.categoryId === 'telehealth5192';
  }
  
  try {
    // Fetch service details from Firestore
    const { doc, getDoc } = await import('firebase/firestore');
    const { db } = await import('@shared/firebase');
    
    const serviceDoc = await getDoc(doc(db, 'services', serviceId));
    if (serviceDoc.exists()) {
      const serviceData = serviceDoc.data();
      // Cache the service data
      servicesCache.value.set(serviceId, serviceData);
      return serviceData.categoryId === 'telehealth5192';
    }
  } catch (error) {
    console.error('Error fetching service details:', error);
  }
  
  return false;
};

// Unified history: fetch pet appointments
const fetchPetAppointments = async () => {
  if (!selectedLocalPet.value || !authStore.user?.userId) {
    console.log('Cannot fetch appointments: no pet selected or user not authenticated');
    return;
  }
  
  // Prevent multiple simultaneous fetches
  if (historyLoading.value) {
    console.log('Already fetching appointments, skipping duplicate call');
    return;
  }
  
  try {
    historyLoading.value = true;
    historyError.value = '';
    
    const petId = selectedLocalPet.value.id;
    console.log('Fetching appointments for pet:', petId);
    
    // Fetch appointments for this specific pet
    const userAppointments = await appointmentStore.fetchAppointmentsByUserId(authStore.user.userId);
    const filteredAppointments = (userAppointments || []).filter(a => a && ((a.petId && a.petId === petId) || (Array.isArray(a.petIds) && a.petIds.includes(petId))));
    
    console.log('Raw user appointments:', userAppointments?.length || 0);
    console.log('Filtered appointments for pet:', petId, filteredAppointments.length);
    console.log('Filtered appointment IDs:', filteredAppointments.map(a => a.id));
    
    petAppointments.value = filteredAppointments;
    
    console.log('Fetched appointments for pet:', petId, petAppointments.value.length);
    console.log('Selected pet data:', selectedLocalPet.value);
    
  } catch (e) {
    console.error('Failed fetching pet appointments:', e);
    historyError.value = 'Failed to load pet appointment history.';
  } finally {
    historyLoading.value = false;
  }
};

// Build timeline
const timelineEntries = computed(() => {
  try {
    const petId = selectedLocalPet.value?.id;
    const filter = historyFilter.value;
    
    console.log('Computing timeline entries for pet:', petId, 'filter:', filter);
    
    if (!selectedLocalPet.value) {
      console.log('No selected pet, returning empty timeline');
      return [];
    }
    
    const entries = [];
    
              // Add appointments (including telehealth) - only add each appointment once
     const processedAppointmentIds = new Set();
     
     console.log('Processing appointments:', petAppointments.value.length);
     console.log('Appointment details:', petAppointments.value.map(a => ({
       id: a.id,
       date: a.date,
       serviceNames: a.serviceNames,
       services: a.services,
       status: a.status,
       type: a.type,
       isTelehealth: a.isTelehealth
     })));
     
     for (const a of petAppointments.value) {
       try {
         console.log('Processing appointment:', a.id, a.serviceNames);
         
         // Skip if we've already processed this appointment
         if (processedAppointmentIds.has(a.id)) {
           console.log('Skipping duplicate appointment ID:', a.id);
           continue;
         }
         
         // Safely create date from appointment data
         let when;
         try {
           if (a.date) {
             when = new Date(a.date);
             // Check if the date is valid
             if (isNaN(when.getTime())) {
               console.warn('Invalid appointment date:', a.date);
               when = new Date();
             }
           } else {
             when = new Date();
           }
         } catch (dateError) {
           console.warn('Error creating date from appointment:', dateError);
           when = new Date();
         }
         
         // Check if this appointment belongs to a specific category based on its services
         let appointmentCategory = null;
         
         if (a.services && Array.isArray(a.services) && a.services.length > 0) {
           // Find which category this appointment's services belong to
           for (const [categoryId, serviceIds] of categoryServiceIds.value.entries()) {
             if (a.services.some(serviceId => serviceIds.includes(serviceId))) {
               appointmentCategory = categoryId;
               console.log('Appointment', a.id, 'matched category:', categoryId);
               break;
             }
           }
         }
         
         // For backward compatibility, also check traditional telehealth indicators
         const isTele = (
           String(a.type || '').toLowerCase() === 'online' || 
           a.isTelehealth === true ||
           appointmentCategory === 'telehealth5192' ||
           // Check service names for telehealth indicators
           (a.serviceNames && Array.isArray(a.serviceNames) && 
            a.serviceNames.some(name => name.toLowerCase().includes('video') || name.toLowerCase().includes('telehealth')))
         );
         
         console.log('Appointment', a.id, 'telehealth check:', {
           type: a.type,
           isTelehealth: a.isTelehealth,
           appointmentCategory,
           isTele
         });
         
         // Apply filter based on category
         if (historyFilter.value !== 'all' && historyFilter.value !== 'vaccinations' && historyFilter.value !== 'completed') {
           // Category-based filtering
           if (historyFilter.value !== appointmentCategory) {
             console.log('Appointment', a.id, 'filtered out by category:', historyFilter.value, 'vs', appointmentCategory);
             continue;
           }
         }
         
         // Special filters
         if (historyFilter.value === 'vaccinations') {
           console.log('Appointment', a.id, 'filtered out by vaccinations filter');
           continue;
         }
         if (historyFilter.value === 'completed' && a.status !== 'completed') {
           console.log('Appointment', a.id, 'filtered out by completed filter');
           continue;
         }
         
         // Get category name for display
         const categoryName = appointmentCategory ? 
           categories.value.find(cat => cat.id === appointmentCategory)?.name || 'Appointment' : 
           (isTele ? 'Telehealth' : 'Appointment');
         
         console.log('Appointment', a.id, 'final category name:', categoryName);
         
         // Ensure we have a valid date before adding to entries
         if (when && !isNaN(when.getTime())) {
           // Check if this is a vaccination appointment
           const isVaccinationAppointment = (Array.isArray(a.serviceNames) && 
             a.serviceNames.some(name => name.toLowerCase().includes('vaccination')));
           
           // For vaccination appointments, create a single entry instead of multiple
           if (isVaccinationAppointment) {
             const entry = {
               kind: 'Vaccination', // Force vaccination kind for vaccination appointments
               date: when,
               title: 'Vaccination Appointment', // Use generic title to prevent duplicates
               subtitle: a.doctorName || a.vetName || '',
               status: (a.status || '').toLowerCase(),
               details: a.notes || '',
               icon: SyringeIcon,
               color: 'text-teal-600',
               completionData: a.completionData || null,
               serviceIds: a.services || [],
               categoryId: appointmentCategory,
               isTelehealth: isTele,
               appointmentId: a.id,
               isVaccinationAppointment: true // Flag to identify vaccination appointments
             };
             
             console.log('Adding vaccination appointment entry for appointment', a.id, ':', entry);
             entries.push(entry);
           } else {
             // Regular appointment entry
             const entry = {
               kind: categoryName,
               date: when,
               title: (Array.isArray(a.serviceNames) && a.serviceNames.length ? a.serviceNames.join(', ') : 'Veterinary appointment'),
               subtitle: a.doctorName || a.vetName || '',
               status: (a.status || '').toLowerCase(),
               details: a.notes || '',
               icon: isTele ? ActivityIcon : FileTextIcon,
               color: isTele ? 'text-indigo-600' : 'text-blue-600',
               completionData: a.completionData || null,
               serviceIds: a.services || [],
               categoryId: appointmentCategory,
               isTelehealth: isTele,
               appointmentId: a.id
             };
             
             console.log('Adding regular appointment entry for appointment', a.id, ':', entry);
             entries.push(entry);
           }
           
           // Mark this appointment as processed
           processedAppointmentIds.add(a.id);
           console.log('Marked appointment', a.id, 'as processed. Total processed:', processedAppointmentIds.size);
         } else {
           console.warn('Skipping appointment with invalid date:', a);
         }
       } catch (appointmentError) {
         console.error('Error processing appointment:', appointmentError, a);
         continue;
       }
     }

         // Add medical history treatments if viewing all records
     if (historyFilter.value === 'all') {
       const mh = selectedLocalPet.value.medicalHistory || [];
       console.log('Medical history data:', mh);
       console.log('Medical history length:', mh.length);
       
       for (const r of mh) {
         try {
           // Safely create date from medical history record
           let when;
           try {
             if (r.date) {
               when = new Date(r.date);
               // Check if the date is valid
               if (isNaN(when.getTime())) {
                 console.warn('Invalid medical history date:', r.date);
                 when = new Date();
               }
             } else {
               when = new Date();
             }
           } catch (dateError) {
             console.warn('Error creating date from medical history:', dateError);
             when = new Date();
           }
           
           // Ensure we have a valid date before adding to entries
           if (when && !isNaN(when.getTime())) {
             entries.push({ 
               kind: 'Treatment', 
               date: when, 
               title: r.type || 'Treatment/Check-up', 
               subtitle: r.vet || '', 
               status: '', 
               details: r.description || '', 
               icon: ActivityIcon, 
               color: 'text-emerald-600' 
             });
           } else {
             console.warn('Skipping medical history record with invalid date:', r);
           }
         } catch (recordError) {
           console.error('Error processing medical history record:', recordError, r);
           continue;
         }
       }
       
       // Skip vaccinations from pet data if we already have them from appointments
       // This prevents duplication between appointment vaccinations and pet vaccinations
       const hasVaccinationAppointments = entries.some(e => 
         (e.kind === 'Appointment' || e.kind === 'Telehealth') && 
         e.title && e.title.toLowerCase().includes('vaccination')
       );
       
       if (!hasVaccinationAppointments) {
         // Only add vaccinations from pet data if no vaccination appointments exist
         const vacs = selectedLocalPet.value.vaccinations || [];
         console.log('Vaccinations data from pet (no vaccination appointments found):', vacs);
         console.log('Vaccinations length:', vacs.length);
         
         for (const v of vacs) {
           try {
             // Safely create date from vaccination record
             let when;
             try {
               if (v.date) {
                 when = new Date(v.date);
                 // Check if the date is valid
                 if (isNaN(when.getTime())) {
                   console.warn('Invalid vaccination date:', v.date);
                   when = new Date();
                 }
               } else {
                 when = new Date();
               }
             } catch (dateError) {
               console.warn('Error creating date from vaccination:', dateError);
               when = new Date();
             }
             
             // Ensure we have a valid date before adding to entries
             if (when && !isNaN(when.getTime())) {
               entries.push({ 
                 kind: 'Vaccination', 
                 date: when, 
                 title: v.name || 'Vaccination', 
                 subtitle: v.completed ? 'Completed' : 'Scheduled', 
                 status: v.completed ? 'completed' : 'pending', 
                 details: '', 
                 icon: SyringeIcon, 
                 color: 'text-teal-600' 
               });
             } else {
               console.warn('Skipping vaccination record with invalid date:', v);
             }
           } catch (vaccinationError) {
             console.error('Error processing vaccination record:', vaccinationError, v);
             continue;
           }
         }
       } else {
         console.log('Skipping pet vaccinations - vaccination appointments already exist');
       }
     }

         // Debug log
     console.log('Total timeline entries before deduplication:', entries.length);
     console.log('Timeline entries breakdown:', {
       appointments: entries.filter(e => e.kind === 'Appointment' || e.kind === 'Telehealth').length,
       treatments: entries.filter(e => e.kind === 'Treatment').length,
       vaccinations: entries.filter(e => e.kind === 'Vaccination').length,
       other: entries.filter(e => !['Appointment', 'Telehealth', 'Treatment', 'Vaccination'].includes(e.kind)).length
     });
     
     // Log first few entries to see their structure
     if (entries.length > 0) {
       console.log('Sample entries structure:', entries.slice(0, 3).map(e => ({
         kind: e.kind,
         title: e.title,
         date: e.date,
         serviceIds: e.serviceIds,
         subtitle: e.subtitle
       })));
     }

         // Remove duplicates based on unique identifiers
     const uniqueEntries = [];
     const seenKeys = new Set();
     
     console.log('Starting duplicate removal. Total entries before:', entries.length);
     
     for (const entry of entries) {
       // Create a unique key for each entry to prevent duplicates
       let uniqueKey;
       
       if (entry.kind === 'Appointment' || entry.kind === 'Telehealth') {
         // For appointments, use appointment ID as the primary unique identifier
         uniqueKey = `appointment_${entry.appointmentId || 'unknown'}`;
         console.log('Appointment unique key:', uniqueKey, 'for entry:', entry);
       } else if (entry.kind === 'Treatment') {
         // For medical history, use type + date + description hash
         uniqueKey = `treatment_${entry.title}_${entry.date?.getTime() || Date.now()}_${entry.details?.substring(0, 50) || ''}`;
         console.log('Treatment unique key:', uniqueKey, 'for entry:', entry);
       } else if (entry.kind === 'Vaccination') {
         // For vaccinations, use a more specific key to prevent duplicates
         // Include title, date, and status to catch variations
         const vaccinationDate = entry.date?.getTime() || Date.now();
         const vaccinationTitle = entry.title || 'Unknown';
         const vaccinationStatus = entry.status || 'unknown';
         uniqueKey = `vaccination_${vaccinationTitle}_${vaccinationDate}_${vaccinationStatus}`;
         console.log('Vaccination unique key:', uniqueKey, 'for entry:', entry);
       } else {
         // Fallback for other types
         uniqueKey = `${entry.kind}_${entry.title}_${entry.date?.getTime() || Date.now()}`;
         console.log('Other unique key:', uniqueKey, 'for entry:', entry);
       }
       
       if (!seenKeys.has(uniqueKey)) {
         seenKeys.add(uniqueKey);
         uniqueEntries.push(entry);
         console.log('Added unique entry:', uniqueKey);
       } else {
         console.log('Skipping duplicate entry with key:', uniqueKey, 'Entry:', entry);
       }
     }
     
     // Sort entries by date (latest first)
     uniqueEntries.sort((a, b) => {
       try {
         const dateA = new Date(a.date);
         const dateB = new Date(b.date);
         
         // Check if dates are valid
         if (isNaN(dateA.getTime()) || isNaN(dateB.getTime())) {
           console.warn('Invalid date found during sorting:', { a: a.date, b: b.date });
           return 0;
         }
         
         // Sort latest first (descending order)
         return dateB - dateA;
       } catch (sortError) {
         console.error('Error sorting entries:', sortError);
         return 0;
       }
     });
     
     console.log('Timeline processing complete:', {
       originalEntries: entries.length,
       uniqueEntries: uniqueEntries.length,
       duplicatesRemoved: entries.length - uniqueEntries.length
     });
     
          return uniqueEntries;
  } catch (error) {
    console.error('Error in timelineEntries computed:', error);
    return [];
  }
});

// Watchers
watch([selectedLocalPet, selectedPetTab, viewMode], ([pet, tab, mode]) => {
  console.log('Watcher triggered:', { pet: pet?.id, tab, mode });
  if (pet && tab === 'medical-history' && mode === 'view') {
    console.log('Fetching pet appointments for medical history tab');
    historyFilter.value = 'all'; // Reset filter when switching pets or entering medical history tab
    fetchPetAppointments();
  }
});

// Save operations (self-contained with own notifications)
const saveAllChanges = async () => {
  console.log('saveAllChanges called - pendingChanges:', pendingChanges.value, 'isSavingChanges:', isSavingChanges.value);
  
  if (!authStore.user || !authStore.user.userId) {
    errorMessage.value = 'User not authenticated. Please log in again.';
    showErrorModal.value = true;
    return false;
  }
  
  if (!pendingChanges.value && deletedPetIds.value.length === 0) {
    statusMessage.value = 'No changes to save.';
    showSuccessModal.value = true;
    return true;
  }
  
  isLoading.value = true;
  isSavingChanges.value = true;
  const userId = authStore.user.userId;
  let success = true;
  
  try {
    // Handle deleted pets
    for (const petId of deletedPetIds.value) {
      const ok = await petsStore.deletePet(userId, petId);
      if (!ok) success = false;
    }
    
    // Handle new and updated pets
    for (const pet of localPets.value) {
      if (pet.id && !pet.changed && !pet.isNew) continue;
      
      const petData = { ...pet };
      delete petData.tempId; 
      delete petData.isNew; 
      delete petData.changed; 
      if (petData.photoFile) delete petData.photoFile;
      
      // Set default values for required fields
      if (!petData.name || petData.name.trim() === '') petData.name = 'Unnamed Pet';
      if (!petData.species || petData.species.trim() === '') petData.species = 'Unspecified';
      if (!petData.breed || petData.breed.trim() === '') petData.breed = 'Unspecified';
      if (!petData.gender || petData.gender.trim() === '') petData.gender = 'Unspecified';
      
      if (!pet.id) {
        // Add new pet
        const added = await petsStore.addPet(userId, petData);
        if (!added) success = false;
      } else if (pet.changed) {
        // Update existing pet
        const ok = await petsStore.updatePet(userId, pet.id, petData);
        if (!ok) success = false;
      }
    }
    
    if (success) {
      // Refresh pets data and reset state
      await fetchPets();
      pendingChanges.value = false;
      deletedPetIds.value = [];
      
      // Show success message
      statusMessage.value = 'Pet information saved successfully!';
      showSuccessModal.value = true;
      
      // Reset to list view after successful save
      selectedPetId.value = null;
      viewMode.value = 'view';
      genderDropdownOpen.value = false;
    } else {
      throw new Error('Failed to save some pet changes. Please try again.');
    }
    
    return success;
  } catch (e) {
    console.error('Error saving pet changes:', e);
    errorMessage.value = e.message || 'An error occurred while saving pet changes. Please try again.';
    showErrorModal.value = true;
    return false;
  } finally {
    isLoading.value = false;
    isSavingChanges.value = false;
  }
};

const hasPendingChanges = () => pendingChanges.value || deletedPetIds.value.length > 0;

// Lifecycle
onMounted(async () => { 
  console.log('Pets component mounted');
  await fetchPets(); 
  console.log('Pets fetched, local pets:', localPets.value);
  await populateCategoriesAndServices(); // Populate categories and services
  
  // Check if we should automatically add a new pet (prioritize over petId)
  if (route.query.addPet === 'true' && !selectedPetId.value) {
    await nextTick(); // Wait for component to be fully rendered
    // Only call addNewPet if we don't already have a new pet from initialization
    addNewPet();
  }
  // Check if we should view a specific pet (only if not adding a new pet)
  else if (route.query.petId && selectedPetId.value === route.query.petId) {
    await nextTick(); // Wait for component to be fully rendered
    const petToView = localPets.value.find(pet => pet.id === route.query.petId);
    if (petToView) {
      // Update the editablePet with the found pet data
      editablePet.value = { ...petToView };
    } else {
      console.warn(`Pet with ID ${route.query.petId} not found`);
      // If pet not found, reset to list view
      selectedPetId.value = null;
    }
  }
  
  console.log('Categories and services populated');
  document.addEventListener('click', handleClickOutside); 
});

// Watch for route changes to handle addPet and petId query parameters
watch(() => [route.query.addPet, route.query.petId], ([addPet, petId]) => {
  nextTick(() => {
    // Prioritize addPet over petId
    if (addPet === 'true' && !selectedPetId.value) {
      addNewPet();
    } else if (petId) {
      const petToView = localPets.value.find(pet => pet.id === petId);
      if (petToView) {
        // Set the selectedPetId immediately to prevent showing the list view
        selectedPetId.value = petId;
        selectedPetTab.value = 'basic-details';
        viewMode.value = 'view';
        // Update the editablePet with the found pet data
        editablePet.value = { ...petToView };
      } else {
        console.warn(`Pet with ID ${petId} not found`);
        // If pet not found, stay in list view
      }
    }
  });
});

onBeforeUnmount(() => { document.removeEventListener('click', handleClickOutside); });
const handleClickOutside = (event) => {
  if (genderDropdownOpen.value && !event.target.closest('.gender-dropdown')) genderDropdownOpen.value = false;
};





// Keep editablePet in sync
watch(selectedLocalPet, (newPet) => { if (newPet) editablePet.value = { ...newPet }; });

// Prevent body scroll when modals are open
watch(showVaccinationCardModal, (isOpen) => {
  if (isOpen) {
    document.body.style.overflow = 'hidden';
  } else {
    document.body.style.overflow = '';
  }
});

watch(showSuccessModal, (isOpen) => {
  if (isOpen) {
    document.body.style.overflow = 'hidden';
  } else {
    document.body.style.overflow = '';
  }
});

watch(showDeleteModal, (isOpen) => {
  if (isOpen) {
    document.body.style.overflow = 'hidden';
  } else {
    document.body.style.overflow = '';
  }
});

watch(showErrorModal, (isOpen) => {
  if (isOpen) {
    document.body.style.overflow = 'hidden';
  } else {
    document.body.style.overflow = '';
  }
});

// Expose
defineExpose({ saveAllChanges, hasPendingChanges, fetchPets });

// Make format function available to template with safe date handling
const formatDate = (date, formatString = 'PPpp') => {
  try {
    if (!date) return 'N/A';
    
    // Handle different date formats
    let validDate;
    if (date instanceof Date) {
      validDate = date;
    } else if (typeof date === 'string' || typeof date === 'number') {
      validDate = new Date(date);
    } else {
      return 'Invalid Date';
    }
    
    // Check if the date is valid
    if (isNaN(validDate.getTime())) {
      console.warn('Invalid date passed to formatDate:', date);
      return 'Invalid Date';
    }
    
    return format(validDate, formatString);
  } catch (error) {
    console.error('Error formatting date:', error, date);
    return 'Date Error';
  }
};



// Vaccination card modal functions
const openVaccinationCardModal = async () => {
  if (!selectedLocalPet.value?.id) {
    console.error('No pet selected for vaccination card');
    return;
  }
  
  // Refresh pet data to ensure we have the latest vaccination records
  try {
    await petsStore.fetchUserPets(authStore.user.userId, true); // Force refresh
    const updatedPets = storedPets.value;
    const updatedPet = updatedPets.find(p => p.id === selectedLocalPet.value.id);
    if (updatedPet) {
      selectedLocalPet.value = updatedPet;
      console.log('Updated pet data with latest vaccination records:', updatedPet.vaccinations);
    }
  } catch (error) {
    console.error('Error refreshing pet data:', error);
  }
  
  // Load vaccination records for the selected pet
  loadVaccinationRecords();
  showVaccinationCardModal.value = true;
};

const loadVaccinationRecords = async () => {
  try {
    if (!selectedLocalPet.value?.id || !authStore.user?.userId) {
      console.error('No pet selected or user not authenticated');
      vaccinationRecords.value = [];
      return;
    }

    // Import Firebase functions
    const { doc, getDoc } = await import('firebase/firestore');
    const { db } = await import('@shared/firebase');

    // First, try to load vaccination records from the pet's vaccinations array
    console.log('Selected pet data:', selectedLocalPet.value);
    console.log('Pet vaccinations array:', selectedLocalPet.value.vaccinations);
    
    if (selectedLocalPet.value.vaccinations && selectedLocalPet.value.vaccinations.length > 0) {
      console.log('Loading vaccination records from pet.vaccinations array:', selectedLocalPet.value.vaccinations);
      
      // Fetch service details to get processing time for each vaccination record
      const recordsWithServiceDetails = await Promise.all(
        selectedLocalPet.value.vaccinations.map(async (record) => {
          let processingTime = record.processingTime || 'N/A';
          
          // If we have a serviceId, fetch the service details to get processing time
          if (record.serviceId) {
            try {
              const serviceDoc = await getDoc(doc(db, 'services', record.serviceId));
              if (serviceDoc.exists()) {
                const serviceData = serviceDoc.data();
                processingTime = serviceData.processingTime || 'N/A';
                console.log(`Service ${record.serviceId} processing time:`, processingTime);
              }
            } catch (error) {
              console.error(`Error fetching service ${record.serviceId}:`, error);
            }
          }
          
          return {
            id: record.id,
            vaccineName: record.name || record.vaccineName || 'Vaccination',
            vaccineType: record.vaccineType || record.classification || 'Standard Vaccine',
            date: record.date?.toDate?.() || new Date(record.date),
            notes: record.notes || record.description || 'Vaccination completed successfully',
            administeredBy: record.administeredBy || record.doctorName || 'Veterinarian',
            location: record.location || 'ProVet Clinic',
            appointmentId: record.appointmentId,
            serviceId: record.serviceId,
            batchNumber: record.batchNumber,
            expiryDate: record.expiryDate?.toDate?.() || record.expiryDate,
            nextDueDate: record.nextDueDate?.toDate?.() || record.nextDueDate,
            completed: record.completed !== false, // Default to true if not specified
            processingTime: processingTime
          };
        })
      );
      
      vaccinationRecords.value = recordsWithServiceDetails;
      
      // Sort vaccinations by date (newest first)
      vaccinationRecords.value = vaccinationRecords.value.sort((a, b) => new Date(b.date) - new Date(a.date));
      console.log('Loaded vaccination records from pet document with service details:', vaccinationRecords.value);
      return;
    }

    // Fallback: If no vaccinations in pet document, try to load from appointments
    console.log('No vaccinations found in pet document, trying to load from appointments...');
    
    const { collection, query, where, getDocs } = await import('firebase/firestore');
    const records = [];
    
    // Fetch appointments for this pet that are completed
    const appointmentsRef = collection(db, 'appointments');
    const appointmentsQuery = query(
      appointmentsRef,
      where('petIds', 'array-contains', selectedLocalPet.value.id),
      where('status', '==', 'completed')
    );
    
    const appointmentsSnapshot = await getDocs(appointmentsQuery);
    
    for (const appointmentDoc of appointmentsSnapshot.docs) {
      const appointmentData = appointmentDoc.data();
      
      // Check if this appointment has vaccination services
      if (appointmentData.services && appointmentData.services.length > 0) {
        // Fetch service details to check if they are vaccinations
        for (const serviceId of appointmentData.services) {
          try {
            const serviceDoc = await getDoc(doc(db, 'services', serviceId));
            if (serviceDoc.exists()) {
              const serviceData = serviceDoc.data();
              
              // Check if this service is a vaccination
              if (serviceData.isVaccination === true) {
                // Create vaccination record from appointment data
                const vaccinationRecord = {
                  id: `${appointmentDoc.id}-${serviceId}`,
                  vaccineName: serviceData.name || 'Vaccination',
                  vaccineType: serviceData.classification || 'Standard Vaccine',
                  date: appointmentData.date?.toDate?.() || new Date(appointmentData.date),
                  notes: appointmentData.completionData?.services?.find(s => s.name === serviceData.name)?.notes || 
                         appointmentData.completionData?.generalNotes?.treatmentSummary || 
                         'Vaccination completed successfully',
                  administeredBy: appointmentData.doctorName || 'Veterinarian',
                  location: appointmentData.location || 'ProVet Clinic',
                  appointmentId: appointmentDoc.id,
                  serviceId: serviceId,
                  processingTime: serviceData.processingTime || 'N/A' // This is the service duration
                };
                
                records.push(vaccinationRecord);
              }
            }
          } catch (serviceError) {
            console.error(`Error fetching service ${serviceId}:`, serviceError);
          }
        }
      }
    }
    
    // Sort vaccinations by date (newest first)
    vaccinationRecords.value = records.sort((a, b) => new Date(b.date) - new Date(a.date));
    
    console.log('Loaded vaccination records from appointments (fallback):', vaccinationRecords.value);
    
  } catch (error) {
    console.error('Error loading vaccination records:', error);
    vaccinationRecords.value = [];
  }
};

const sortedVaccinationRecords = computed(() => {
  return [...vaccinationRecords.value].sort((a, b) => new Date(b.date) - new Date(a.date));
});

const getVaccinationStatusClass = (record) => {
  if (record.completed) return 'bg-green-100 text-green-800';
  return 'bg-blue-100 text-blue-800';
};

const getVaccinationStatusText = (record) => {
  if (record.completed) return 'Completed';
  return 'Scheduled';
};

const printVaccinationCard = () => {
  // Create a print-friendly version
  const printWindow = window.open('', '_blank');
  
  // Get current date
  const currentDate = new Date().toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
  
  // Create professional veterinary clinic vaccination card HTML
  const printHTML = `
    <!DOCTYPE html>
    <html>
      <head>
        <title>Vaccination Record - ${selectedLocalPet.value?.name || 'Pet'}</title>
        <style>
          @page {
            size: A4;
            margin: 0.5in;
          }
          
          body {
            font-family: 'Times New Roman', 'Georgia', serif;
            margin: 0;
            padding: 0;
            background: white;
            color: #000;
            line-height: 1.0;
            font-size: 8pt;
          }
          
          .document {
            max-width: 8.5in;
            margin: 0 auto;
            background: white;
            border: 1px solid #000;
            position: relative;
          }
          
          .header {
            background: #fff;
            border-bottom: 0.5px solid #000;
            padding: 3px 10px;
            text-align: center;
            position: relative;
          }
          
          .clinic-info {
            margin-bottom: 2px;
          }
          
          .clinic-name {
            font-size: 12pt;
            font-weight: bold;
            color: #000;
            margin: 0 0 1px 0;
            letter-spacing: 0.5px;
          }
          
          .clinic-subtitle {
            font-size: 7pt;
            color: #333;
            margin: 0 0 1px 0;
            font-style: italic;
          }
          
          .clinic-details {
            font-size: 10pt;
            color: #666;
            line-height: 1.3;
          }
          
          .document-title {
            background: #000;
            color: #fff;
            padding: 15px;
            text-align: center;
            font-size: 18pt;
            font-weight: bold;
            letter-spacing: 2px;
            margin: 0;
          }
          
          .content {
            padding: 30px;
          }
          
          .pet-section {
            border: 2px solid #000;
            margin-bottom: 25px;
            background: #f9f9f9;
          }
          
          .section-header {
            background: #000;
            color: #fff;
            padding: 10px 15px;
            font-size: 14pt;
            font-weight: bold;
            text-align: center;
          }
          
          .pet-info {
            padding: 20px;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
          }
          
          .info-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 0;
            border-bottom: 1px dotted #ccc;
          }
          
          .info-item:last-child {
            border-bottom: none;
          }
          
          .info-label {
            font-weight: bold;
            min-width: 120px;
          }
          
          .info-value {
            text-align: right;
            flex: 1;
            margin-left: 10px;
          }
          
          .owner-section {
            border: 2px solid #000;
            margin-bottom: 25px;
            background: #f9f9f9;
          }
          
          .owner-info {
            padding: 20px;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
          }
          
          .vaccination-section {
            border: 2px solid #000;
            margin-bottom: 25px;
            background: #f9f9f9;
          }
          
          .vaccination-records {
            padding: 20px;
          }
          
          .vaccination-record {
            border: 1px solid #000;
            margin-bottom: 15px;
            background: white;
            page-break-inside: avoid;
          }
          
          .record-header {
            background: #e0e0e0;
            padding: 10px 15px;
            border-bottom: 1px solid #000;
            display: flex;
            justify-content: space-between;
            align-items: center;
          }
          
          .vaccine-name {
            font-size: 14pt;
            font-weight: bold;
            color: #000;
          }
          
          .vaccine-date {
            font-size: 12pt;
            font-weight: bold;
            color: #000;
          }
          
          .record-details {
            padding: 15px;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
          }
          
          .detail-item {
            display: flex;
            justify-content: space-between;
            padding: 5px 0;
            border-bottom: 1px dotted #ccc;
          }
          
          .detail-item:last-child {
            border-bottom: none;
          }
          
          .detail-label {
            font-weight: bold;
            min-width: 100px;
          }
          
          .detail-value {
            text-align: right;
            flex: 1;
            margin-left: 10px;
          }
          
          .notes-section {
            grid-column: 1 / -1;
            margin-top: 10px;
            padding-top: 10px;
            border-top: 1px solid #ccc;
          }
          
          .notes-label {
            font-weight: bold;
            margin-bottom: 5px;
          }
          
          .notes-content {
            font-style: italic;
            background: #f5f5f5;
            padding: 8px;
            border: 1px solid #ccc;
          }
          
          .no-records {
            text-align: center;
            padding: 30px;
            color: #666;
            font-style: italic;
          }
          
          .footer {
            background: #000;
            color: #fff;
            padding: 15px 30px;
            text-align: center;
            font-size: 10pt;
          }
          
          .footer-info {
            margin-bottom: 5px;
          }
          
          .generated-info {
            font-size: 9pt;
            opacity: 0.8;
          }
          
          .watermark {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) rotate(-45deg);
            font-size: 48pt;
            color: rgba(0, 0, 0, 0.05);
            font-weight: bold;
            z-index: -1;
            pointer-events: none;
          }
          
          @media print {
            body { margin: 0; }
            .document { border: 2px solid #000; }
            .watermark { display: none; }
          }
        </style>
      </head>
      <body>
        <div class="document">
          <div class="watermark">OFFICIAL</div>
          
        <div class="header">
            <div class="clinic-info">
              <div class="clinic-name">INNOVET VETERINARY CLINIC</div>
              <div class="clinic-details">
                Capitol Complex, Calapan City, Oriental Mindoro<br>
                Phone: (043) 288 7743
              </div>
            </div>
        </div>
          
          <h1 class="document-title">VACCINATION RECORD</h1>
          
          <div class="content">
        
        <div class="pet-section">
              <div class="section-header">PET INFORMATION</div>
              <div class="pet-info">
                <div class="info-item">
                  <span class="info-label">Pet Name:</span>
                  <span class="info-value">${selectedLocalPet.value?.name || 'N/A'}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Species:</span>
                  <span class="info-value">${selectedLocalPet.value?.species || 'N/A'}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Breed:</span>
                  <span class="info-value">${selectedLocalPet.value?.breed || 'N/A'}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Age:</span>
                  <span class="info-value">${selectedLocalPet.value?.ageYears || 0} years ${selectedLocalPet.value?.ageMonths || 0} months</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Gender:</span>
                  <span class="info-value">${selectedLocalPet.value?.gender || 'N/A'}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Weight:</span>
                  <span class="info-value">${selectedLocalPet.value?.weight ? selectedLocalPet.value.weight + ' kg' : 'N/A'}</span>
                </div>
            </div>
          </div>
          
            <div class="owner-section">
              <div class="section-header">OWNER INFORMATION</div>
          <div class="owner-info">
                <div class="info-item">
              <span class="info-label">Owner Name:</span>
              <span class="info-value">${authStore.user?.firstName || ''} ${authStore.user?.lastName || ''}</span>
            </div>
                <div class="info-item">
                  <span class="info-label">Phone:</span>
                  <span class="info-value">${authStore.user?.phone || 'N/A'}</span>
            </div>
                <div class="info-item">
                  <span class="info-label">Email:</span>
                  <span class="info-value">${authStore.user?.email || 'N/A'}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Record Date:</span>
              <span class="info-value">${currentDate}</span>
            </div>
          </div>
        </div>
        
            <div class="vaccination-section">
              <div class="section-header">VACCINATION HISTORY</div>
              <div class="vaccination-records">
          ${vaccinationRecords.value.length > 0 ? 
            vaccinationRecords.value.map(record => `
              <div class="vaccination-record">
                <div class="record-header">
                        <div class="vaccine-name">${record.vaccineName || 'Vaccination'}</div>
                        <div class="vaccine-date">${formatDate(record.date, 'MMM dd, yyyy')}</div>
                  </div>
                <div class="record-details">
                        <div class="detail-item">
                          <span class="detail-label">Vaccine Type:</span>
                          <span class="detail-value">${record.vaccineType || 'Standard Vaccine'}</span>
                        </div>
                        <div class="detail-item">
                          <span class="detail-label">Duration:</span>
                    <span class="detail-value">${record.processingTime || 'N/A'}</span>
                  </div>
                        <div class="detail-item">
                    <span class="detail-label">Administered By:</span>
                    <span class="detail-value">${record.administeredBy || 'Veterinarian'}</span>
                  </div>
                        <div class="detail-item">
                    <span class="detail-label">Location:</span>
                    <span class="detail-value">${record.location || 'ProVet Clinic'}</span>
                  </div>
                        <div class="detail-item">
                    <span class="detail-label">Appointment ID:</span>
                    <span class="detail-value">${record.appointmentId || 'N/A'}</span>
                  </div>
                        ${record.batchNumber ? `
                          <div class="detail-item">
                            <span class="detail-label">Batch Number:</span>
                            <span class="detail-value">${record.batchNumber}</span>
                    </div>
                  ` : ''}
                        ${record.expiryDate ? `
                          <div class="detail-item">
                            <span class="detail-label">Expiry Date:</span>
                            <span class="detail-value">${formatDate(record.expiryDate, 'MMM dd, yyyy')}</span>
                </div>
                        ` : ''}
                        ${record.nextDueDate ? `
                          <div class="detail-item">
                            <span class="detail-label">Next Due:</span>
                            <span class="detail-value">${formatDate(record.nextDueDate, 'MMM dd, yyyy')}</span>
              </div>
                        ` : ''}
                        ${record.notes ? `
                          <div class="notes-section">
                            <div class="notes-label">Veterinarian Notes:</div>
                            <div class="notes-content">${record.notes}</div>
                </div>
                        ` : ''}
              </div>
                    </div>
                  `).join('') : 
                  `<div class="no-records">
                    <p>No vaccination records found for ${selectedLocalPet.value?.name || 'this pet'}.</p>
                    <p>Please contact your veterinarian to schedule vaccinations.</p>
            </div>`
          }
              </div>
            </div>
        </div>
        
        <div class="footer">
            <div class="footer-info">
              <strong>INNOVET VETERINARY CLINIC</strong>
            </div>
            <div class="generated-info">
              This is an official vaccination record. Generated on ${currentDate}
            </div>
          </div>
        </div>
      </body>
    </html>
  `;
  
  printWindow.document.write(printHTML);
  printWindow.document.close();
  printWindow.focus();
  
  // Wait for content to load then print
  setTimeout(() => {
    printWindow.print();
    printWindow.close();
  }, 1000);
};

// Generate vaccination card PDF content (similar to HistoryPanel's generatePrescriptionPDF)
const generateVaccinationCardPDF = (currentDate) => {
  const pet = selectedLocalPet.value;
  const user = authStore.user;
  
  // Debug: Log the data being used
  console.log('Generating PDF with data:', {
    pet: pet,
    user: user,
    vaccinationRecords: vaccinationRecords.value,
    currentDate: currentDate
  });
  
  // Create vaccination records HTML
  let vaccinationRecordsHTML = '';
  if (vaccinationRecords.value && vaccinationRecords.value.length > 0) {
    vaccinationRecordsHTML = vaccinationRecords.value.map(record => `
      <div class="vaccination-record">
        <div class="record-header">
          <div class="vaccine-name">${record.vaccineName || 'Vaccination'}</div>
          <div class="vaccine-date">${formatDate(record.date, 'MMM dd, yyyy')}</div>
            </div>
        <div class="record-details">
          <div class="detail-item">
            <span class="detail-label">Vaccine Type:</span>
            <span class="detail-value">${record.vaccineType || 'Standard Vaccine'}</span>
          </div>
          <div class="detail-item">
            <span class="detail-label">Duration:</span>
            <span class="detail-value">${record.processingTime || 'N/A'}</span>
        </div>
          <div class="detail-item">
            <span class="detail-label">Administered By:</span>
            <span class="detail-value">${record.administeredBy || 'Veterinarian'}</span>
              </div>
          <div class="detail-item">
            <span class="detail-label">Location:</span>
            <span class="detail-value">${record.location || 'ProVet Clinic'}</span>
              </div>
          <div class="detail-item">
            <span class="detail-label">Appointment ID:</span>
            <span class="detail-value">${record.appointmentId || 'N/A'}</span>
              </div>
          ${record.batchNumber ? `
            <div class="detail-item">
              <span class="detail-label">Batch Number:</span>
              <span class="detail-value">${record.batchNumber}</span>
              </div>
          ` : ''}
          ${record.expiryDate ? `
            <div class="detail-item">
              <span class="detail-label">Expiry Date:</span>
              <span class="detail-value">${formatDate(record.expiryDate, 'MMM dd, yyyy')}</span>
              </div>
          ` : ''}
          ${record.nextDueDate ? `
            <div class="detail-item">
              <span class="detail-label">Next Due:</span>
              <span class="detail-value">${formatDate(record.nextDueDate, 'MMM dd, yyyy')}</span>
              </div>
          ` : ''}
          ${record.notes ? `
            <div class="notes-section">
              <div class="notes-label">Veterinarian Notes:</div>
              <div class="notes-content">${record.notes}</div>
            </div>
          ` : ''}
          </div>
            </div>
    `).join('');
  } else {
    vaccinationRecordsHTML = `
      <div class="no-records">
        <p>No vaccination records found for ${pet?.name || 'this pet'}.</p>
        <p>Please contact your veterinarian to schedule vaccinations.</p>
            </div>
    `;
  }
  
  return `
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <title>Vaccination Record - ${pet?.name || 'Pet'}</title>
        <style>
          @page {
            size: letter;
            margin: 0.5in;
          }
          
          body {
            font-family: 'Times New Roman', 'Georgia', serif;
            margin: 0;
            padding: 0;
            background: white;
            color: #000;
            line-height: 1.2;
            font-size: 10pt;
          }
          
          .document {
            max-width: 7.5in;
            margin: 0 auto;
            background: white;
            border: 1px solid #000;
            position: relative;
            min-height: 10in;
          }
          
          .header {
            background: #fff;
            border-bottom: 1px solid #000;
            padding: 10px 15px;
            text-align: center;
            position: relative;
          }
          
          .clinic-name {
            font-size: 16pt;
            font-weight: bold;
            color: #000;
            margin: 0 0 5px 0;
            letter-spacing: 0.5px;
          }
          
          .clinic-details {
            font-size: 10pt;
            color: #666;
            line-height: 1.2;
          }
          
          .document-title {
            background: #000;
            color: #fff;
            padding: 15px;
            text-align: center;
            font-size: 18pt;
            font-weight: bold;
            letter-spacing: 1px;
            margin: 0;
          }
          
          .content {
            padding: 20px;
          }
          
          .section {
            border: 1px solid #000;
            margin-bottom: 18px;
            background: #f9f9f9;
          }
          
          .section-header {
            background: #000;
            color: #fff;
            padding: 10px 15px;
            font-size: 14pt;
            font-weight: bold;
            text-align: center;
          }
          
          .section-content {
            padding: 15px;
          }
          
          .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
          }
          
          .info-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 6px 0;
            border-bottom: 1px dotted #ccc;
          }
          
          .info-item:last-child {
            border-bottom: none;
          }
          
          .info-label {
            font-weight: bold;
            min-width: 90px;
            font-size: 10pt;
          }
          
          .info-value {
            text-align: right;
            flex: 1;
            margin-left: 10px;
            font-size: 10pt;
          }
          
          .vaccination-record {
            border: 1px solid #000;
            margin-bottom: 12px;
            background: white;
            page-break-inside: avoid;
          }
          
          .record-header {
            background: #e0e0e0;
            padding: 8px 12px;
            border-bottom: 1px solid #000;
            display: flex;
            justify-content: space-between;
            align-items: center;
          }
          
          .vaccine-name {
            font-size: 13pt;
            font-weight: bold;
            color: #000;
          }
          
          .vaccine-date {
            font-size: 11pt;
            font-weight: bold;
            color: #000;
          }
          
          .record-details {
            padding: 10px;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 8px;
          }
          
          .detail-item {
            display: flex;
            justify-content: space-between;
            padding: 4px 0;
            border-bottom: 1px dotted #ccc;
          }
          
          .detail-item:last-child {
            border-bottom: none;
          }
          
          .detail-label {
            font-weight: bold;
            min-width: 80px;
            font-size: 9pt;
          }
          
          .detail-value {
            text-align: right;
            flex: 1;
            margin-left: 8px;
            font-size: 9pt;
          }
          
          .notes-section {
            grid-column: 1 / -1;
            margin-top: 8px;
            padding-top: 8px;
            border-top: 1px solid #ccc;
          }
          
          .notes-label {
            font-weight: bold;
            margin-bottom: 4px;
            font-size: 10pt;
          }
          
          .notes-content {
            font-style: italic;
            background: #f5f5f5;
            padding: 8px;
            border: 1px solid #ccc;
            font-size: 9pt;
          }
          
          .no-records {
            text-align: center;
            padding: 25px;
            color: #666;
            font-style: italic;
            font-size: 12pt;
          }
          
          .footer {
            background: #000;
            color: #fff;
            padding: 12px 20px;
            text-align: center;
            font-size: 10pt;
            margin-top: auto;
          }
          
          .footer-info {
            margin-bottom: 4px;
          }
          
          .generated-info {
            font-size: 9pt;
            opacity: 0.8;
          }
          
          .watermark {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) rotate(-45deg);
            font-size: 48pt;
            color: rgba(0, 0, 0, 0.05);
            font-weight: bold;
            z-index: -1;
            pointer-events: none;
          }
        </style>
      </head>
      <body>
        <div class="document">
          <div class="watermark">OFFICIAL</div>
          
          <div class="header">
            <div class="clinic-name">INNOVET VETERINARY CLINIC</div>
            <div class="clinic-details">
              Capitol Complex, Calapan City, Oriental Mindoro<br>
              Phone: (043) 288 7743
          </div>
        </div>
        
          <h1 class="document-title">VACCINATION RECORD</h1>
          
          <div class="content">
            <!-- Pet Information Section -->
            <div class="section">
              <div class="section-header">PET INFORMATION</div>
              <div class="section-content">
                <div class="info-grid">
                  <div class="info-item">
                    <span class="info-label">Pet Name:</span>
                    <span class="info-value">${pet?.name || 'N/A'}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Species:</span>
                    <span class="info-value">${pet?.species || 'N/A'}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Breed:</span>
                    <span class="info-value">${pet?.breed || 'N/A'}</span>
                </div>
                  <div class="info-item">
                    <span class="info-label">Age:</span>
                    <span class="info-value">${pet?.ageYears || 0} years ${pet?.ageMonths || 0} months</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Gender:</span>
                    <span class="info-value">${pet?.gender || 'N/A'}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Weight:</span>
                    <span class="info-value">${pet?.weight ? pet.weight + ' kg' : 'N/A'}</span>
                  </div>
                  </div>
                        </div>
                        </div>
            
            <!-- Owner Information Section -->
            <div class="section">
              <div class="section-header">OWNER INFORMATION</div>
              <div class="section-content">
                <div class="info-grid">
                  <div class="info-item">
                    <span class="info-label">Owner Name:</span>
                    <span class="info-value">${user?.firstName || ''} ${user?.lastName || ''}</span>
                    </div>
                  <div class="info-item">
                    <span class="info-label">Phone:</span>
                    <span class="info-value">${user?.phone || 'N/A'}</span>
                </div>
                  <div class="info-item">
                    <span class="info-label">Email:</span>
                    <span class="info-value">${user?.email || 'N/A'}</span>
              </div>
                  <div class="info-item">
                    <span class="info-label">Record Date:</span>
                    <span class="info-value">${currentDate}</span>
                </div>
              </div>
              </div>
        </div>
        
            <!-- Vaccination History Section -->
            <div class="section">
              <div class="section-header">VACCINATION HISTORY</div>
              <div class="section-content">
                ${vaccinationRecordsHTML}
          </div>
            </div>
            </div>
          
          <div class="footer">
            <div class="footer-info">
              <strong>INNOVET VETERINARY CLINIC</strong>
          </div>
            <div class="generated-info">
              This is an official vaccination record. Generated on ${currentDate}
        </div>
      </div>
        </div>
      </body>
    </html>
  `;
};

const downloadVaccinationCard = async () => {
  try {
    isGeneratingPDF.value = true;
    
    // Debug: Check if we have the required data
    console.log('Downloading vaccination card...');
    console.log('Selected pet:', selectedLocalPet.value);
    console.log('Vaccination records:', vaccinationRecords.value);
    console.log('User:', authStore.user);
    
    // Ensure vaccination records are loaded
    if (vaccinationRecords.value.length === 0) {
      console.log('No vaccination records found, loading them...');
      await loadVaccinationRecords();
    }
    
    // Import required libraries (same approach as HistoryPanel.vue)
    const { default: jsPDF } = await import('jspdf');
    const html2canvas = (await import('html2canvas')).default;
    
    // Get current date
    const currentDate = new Date().toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
    
    // Create vaccination card content using the same approach as HistoryPanel
    const vaccinationCardHTML = generateVaccinationCardPDF(currentDate);
    
    // Debug: Log the generated HTML
    console.log('Generated HTML length:', vaccinationCardHTML.length);
    console.log('HTML preview:', vaccinationCardHTML.substring(0, 500));
    
    // Create a temporary container for the PDF content
    const tempContainer = document.createElement('div');
    tempContainer.style.position = 'absolute';
    tempContainer.style.left = '-9999px';
    tempContainer.style.top = '-9999px';
    tempContainer.style.width = '7.5in'; // Match document width
    tempContainer.style.backgroundColor = 'white';
    tempContainer.style.fontSize = '10pt'; // Match document font size
    tempContainer.innerHTML = vaccinationCardHTML;
    document.body.appendChild(tempContainer);
    
    // Debug: Check if content is rendered
    console.log('Container innerHTML length:', tempContainer.innerHTML.length);
    console.log('Container scroll dimensions:', {
      width: tempContainer.scrollWidth,
      height: tempContainer.scrollHeight
    });

    // Wait for fonts and images to load
    await new Promise(resolve => setTimeout(resolve, 2000));

    // Convert HTML to canvas
    const canvas = await html2canvas(tempContainer, {
        scale: 2,
        useCORS: true,
        letterRendering: true,
      backgroundColor: '#ffffff',
      width: tempContainer.scrollWidth,
      height: tempContainer.scrollHeight,
      logging: true // Enable logging for debugging
    });

    // Debug: Check canvas
    console.log('Canvas dimensions:', {
      width: canvas.width,
      height: canvas.height
    });

    // Remove temporary container
    document.body.removeChild(tempContainer);

    // Create PDF
    const pdf = new jsPDF({
      orientation: 'portrait',
      unit: 'in',
      format: 'letter'
    });

    const imgWidth = 7.5; // Match document width
    const pageHeight = 11;
    const imgHeight = (canvas.height * imgWidth) / canvas.width;
    
    // Debug: Log dimensions
    console.log('Canvas dimensions:', {
      width: canvas.width,
      height: canvas.height,
      imgWidth: imgWidth,
      imgHeight: imgHeight,
      pageHeight: pageHeight
    });

    // Add image to PDF with proper margins
    const imgData = canvas.toDataURL('image/png');
    
    // Check if content fits on one page
    if (imgHeight <= (pageHeight - 1)) {
      // Content fits on one page, add with margins
      pdf.addImage(imgData, 'PNG', 0.5, 0.5, imgWidth, imgHeight);
      console.log('Content fits on single page');
    } else {
      // Content is too tall, need to split across pages
      let heightLeft = imgHeight;
      let position = 0.5; // Start with top margin
      const contentHeight = pageHeight - 1; // Available height per page (11" - 1" margins)
      
      // Add first page
      pdf.addImage(imgData, 'PNG', 0.5, position, imgWidth, imgHeight);
      heightLeft -= contentHeight;
      
      // Add additional pages only if there's significant content left
      while (heightLeft > 0.5) { // Only add page if more than 0.5" of content remains
        position = 0.5; // Reset position for new page
        pdf.addPage();
        pdf.addImage(imgData, 'PNG', 0.5, position - (imgHeight - heightLeft), imgWidth, imgHeight);
        heightLeft -= contentHeight;
        console.log('Added additional page, height left:', heightLeft);
      }
    }

    // Save the PDF
    const fileName = `Vaccination_Card_${selectedLocalPet.value?.name || 'Pet'}_${currentDate.replace(/\//g, '-')}.pdf`;
    pdf.save(fileName);
    
    console.log('Vaccination card PDF downloaded successfully');
    
  } catch (error) {
    console.error('Error generating PDF:', error);
    alert('PDF generation failed. Please try the print option instead.');
  } finally {
    isGeneratingPDF.value = false;
  }
};
</script>

<style scoped>
.overflow-x-auto { scrollbar-width: none; -ms-overflow-style: none; }
.overflow-x-auto::-webkit-scrollbar { display: none; }

/* Print styles for vaccination card */
@media print {
  /* Hide everything except the vaccination card modal */
  body * {
    visibility: hidden;
  }
  
  #vaccination-card-content,
  #vaccination-card-content * {
    visibility: visible !important;
  }
  
  /* Position the vaccination card at the top of the page */
  #vaccination-card-content {
    position: absolute !important;
    top: 0 !important;
    left: 0 !important;
    width: 100% !important;
    height: auto !important;
    margin: 0 !important;
    padding: 0 !important;
    background: white !important;
    box-shadow: none !important;
    border-radius: 0 !important;
  }
  
  /* Ensure proper page breaks */
  .vaccination-record {
    page-break-inside: avoid;
  }
  
  /* Optimize spacing for print */
  .p-6 {
    padding: 0.5in !important;
  }
  
  /* Ensure colors print properly */
  .bg-gradient-to-r {
    background: #2563eb !important;
  }
  
  .bg-gray-50 {
    background: #f9fafb !important;
  }
  
  .text-white {
    color: black !important;
  }
  
  .text-blue-100 {
    color: #1e40af !important;
  }
  
  /* Hide action buttons in print */
  .flex.justify-center.gap-4.mt-8.pt-6.border-t.border-gray-200 {
    display: none !important;
  }
  
  /* Ensure text is readable */
  body {
    font-size: 12pt;
    line-height: 1.4;
  }
  
  /* Page setup */
  @page {
    size: A4;
    margin: 0.5in;
  }
}
</style>

