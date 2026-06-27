<template>
  <div class="p-3 sm:p-4 md:p-6 bg-white rounded-2xl">
    <!-- Header Section -->
    <div class="mb-6 sm:mb-8">
      <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between mb-4 sm:mb-6 gap-4">
        <div>
          <h1 class="text-xl sm:text-2xl font-semibold text-gray-900">Tentative Pet Health Assessment</h1>
          <p class="text-sm sm:text-base text-gray-500 mt-1">Comprehensive health analysis and diagnostic support</p>
        </div>
       
        <!-- Progress Section -->
        <div class="flex items-center gap-4">
          <span class="text-sm font-medium text-blue-600">{{ formCompletionPercentage }}% Complete</span>
          <div class="w-32 h-2 bg-gray-200 rounded-full overflow-hidden">
            <div class="h-full bg-gradient-to-r from-blue-500 to-emerald-500 rounded-full transition-all duration-300" :style="{ width: `${formCompletionPercentage}%` }"></div>
          </div>
        </div>
      </div>
    </div>


    <!-- Connection Error Alert -->
    <div v-if="connectionStatus === false" class="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg flex items-center gap-3">
      <AlertTriangle class="w-5 h-5 text-red-500 flex-shrink-0" />
      <div class="flex-1">
        <span class="text-red-700 font-medium">Connection Error:</span>
        <span class="text-red-600 ml-1">Cannot connect to the prediction server.</span>
      </div>
      <button @click="reconnectWebSocket" class="px-4 py-2 bg-red-500 text-white rounded-lg text-sm font-medium hover:bg-red-600 transition-colors flex items-center gap-2">
        <RefreshCw size="16" />
        Reconnect
      </button>
    </div>
   
    <!-- Form Content -->
    <div v-if="!predictionResult" class="bg-white rounded-lg border border-gray-200 mb-6">
      <div class="p-4 sm:p-6 border-b border-gray-200">
        <h2 class="text-lg sm:text-xl font-bold text-gray-900">Health Assessment Form</h2>
        <p class="text-xs sm:text-sm text-gray-600 mt-1">Complete the form below to get comprehensive health analysis</p>
      </div>
     
      <div class="p-4 sm:p-6">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 sm:gap-8">
          <!-- Pet Information Section -->
          <div class="space-y-4 sm:space-y-6">
            <div class="flex items-center gap-3 mb-4 sm:mb-6">
              <div class="w-8 h-8 sm:w-10 sm:h-10 bg-blue-100 rounded-xl flex items-center justify-center">
                <PawPrint class="w-4 h-4 sm:w-5 sm:h-5 text-blue-600" />
              </div>
              <div>
                <h3 class="text-lg sm:text-xl font-semibold text-gray-900">Pet Information</h3>
                <p class="text-xs sm:text-sm text-gray-500">Enter your pet's basic information</p>
              </div>
            </div>
           
            <!-- Pet Name -->
            <div class="relative">
              <label for="pet-name" class="block text-xs sm:text-sm font-medium text-gray-700 mb-2">Pet Name <span class="text-red-500">*</span></label>
              <input
                id="pet-name"
                v-model="petSearchQuery"
                @input="onPetNameInput"
                @blur="hidePetSuggestions"
                @focus="petSearchQuery.length > 0 && searchPets()"
                type="text"
                placeholder="Enter pet name (or select from suggestions)"
                class="w-full px-3 sm:px-4 py-2 sm:py-3 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-100 focus:border-blue-400 outline-none transition-all text-sm sm:text-base"
              />
             
              <!-- Pet Suggestions Dropdown -->
              <div v-if="showPetSuggestions" class="absolute z-50 w-full mt-1 bg-white border border-gray-200 rounded-lg shadow-lg max-h-60 overflow-y-auto">
                <div v-if="petSuggestions.length > 0">
                  <div v-for="pet in petSuggestions" :key="pet.id"
                       @mousedown="selectPet(pet)"
                       class="px-3 py-2 hover:bg-gray-50 cursor-pointer border-b border-gray-100 last:border-b-0">
                    <div class="flex items-center justify-between">
                      <div class="flex-1">
                        <div class="font-medium text-gray-900">{{ pet.name }}</div>
                        <div class="text-xs text-gray-500">
                          {{ pet.species || 'Unknown species' }} • {{ pet.breed || 'Unknown breed' }}
                          <span v-if="formatPetAgeForDisplay(pet) !== 'No age'"> • {{ formatPetAgeForDisplay(pet) }}</span>
                        </div>
                        <div v-if="pet.ownerName" class="text-xs text-gray-400 mt-1">
                          Owner: {{ pet.ownerName }}
                        </div>
                      </div>
                      <div class="text-xs text-gray-400 ml-2">
                        {{ pet.weight ? pet.weight + ' kg' : 'No weight' }}
                      </div>
                    </div>
                  </div>
                </div>
                <div v-else class="px-3 py-2 text-gray-500 text-sm">
                  No pets found matching "{{ petSearchQuery }}"
                </div>
              </div>
            </div>
             
            <!-- Species -->
            <div>
              <label for="species" class="block text-xs sm:text-sm font-medium text-gray-700 mb-2">Species</label>
              <select
                id="species"
                v-model="species"
                class="w-full px-3 sm:px-4 py-2 sm:py-3 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-100 focus:border-blue-400 outline-none transition-all appearance-none text-sm sm:text-base"
              >
                <option value="">Select species</option>
                <option value="dog">Dog</option>
                <option value="cat">Cat</option>
                <option value="hamster">Hamster</option>
                <option value="rabbit">Rabbit</option>
              </select>
            </div>
           
            <!-- Age and Weight -->
            <div class="grid grid-cols-2 gap-3 sm:gap-4">
              <div>
                <label for="age" class="block text-xs sm:text-sm font-medium text-gray-700 mb-2">Age</label>
                <input
                  id="age"
                  v-model="petAgeDisplay"
                  type="text"
                  placeholder="Enter age (e.g., 2 years, 3 months)"
                  class="w-full px-3 sm:px-4 py-2 sm:py-3 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-100 focus:border-blue-400 outline-none transition-all text-sm sm:text-base"
                />
              </div>
             
              <div>
                <label for="weight" class="block text-xs sm:text-sm font-medium text-gray-700 mb-2">Weight (kg)</label>
                <input
                  id="weight"
                  v-model.number="patientData['Weight (kg)']"
                  type="number"
                  step="0.1"
                  min="0"
                  placeholder="Enter weight"
                  class="w-full px-3 sm:px-4 py-2 sm:py-3 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-100 focus:border-blue-400 outline-none transition-all text-sm sm:text-base"
                />
              </div>
            </div>
           
            <!-- Breed -->
            <div>
              <label for="breed" class="block text-xs sm:text-sm font-medium text-gray-700 mb-2">Breed</label>
              <select
                id="breed"
                v-model="patientData.Breed"
                :disabled="!species"
                class="w-full px-3 sm:px-4 py-2 sm:py-3 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-100 focus:border-blue-400 outline-none transition-all appearance-none text-sm sm:text-base disabled:bg-gray-100 disabled:text-gray-500 disabled:cursor-not-allowed"
              >
                <option value="">{{ species ? 'Select breed' : 'Select species first' }}</option>
                <option v-for="(breed, index) in breedOptions" :key="index" :value="breed">
                  {{ breed }}
                </option>
              </select>
            </div>


            <!-- Vaccination Status -->
            <div>
              <label for="vaccination-status" class="block text-xs sm:text-sm font-medium text-gray-700 mb-2">Vaccination Status</label>
              <select
                id="vaccination-status"
                v-model="patientData['Vaccination_Status']"
                class="w-full px-3 sm:px-4 py-2 sm:py-3 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-100 focus:border-blue-400 outline-none transition-all appearance-none text-sm sm:text-base"
              >
                <option value="up-to-date">Fully Vaccinated</option>
                <option value="partial">Partially Vaccinated</option>
                <option value="none">Unvaccinated</option>
                <option value="unknown">Unknown</option>
              </select>
             
              <!-- Vaccination History Display -->
              <div v-if="selectedPetVaccinations && selectedPetVaccinations.length > 0" class="mt-3 p-3 bg-blue-50 border border-blue-200 rounded-lg">
                <div class="flex items-center gap-2 mb-2">
                  <div class="w-2 h-2 bg-blue-500 rounded-full"></div>
                  <span class="text-xs font-medium text-blue-700">Recent Vaccinations</span>
                </div>
                <div class="space-y-1">
                  <div v-for="vaccination in selectedPetVaccinations.slice(0, 3)" :key="vaccination.id"
                       class="text-xs text-blue-600 flex justify-between items-center">
                    <span>{{ vaccination.name || vaccination.vaccineName }}</span>
                    <span class="text-blue-500">{{ formatVaccinationDate(vaccination.date) }}</span>
                  </div>
                  <div v-if="selectedPetVaccinations.length > 3" class="text-xs text-blue-500 italic">
                    +{{ selectedPetVaccinations.length - 3 }} more vaccination(s)
                  </div>
                </div>
              </div>
            </div>
          </div>
       
          <!-- Symptoms & Health History Section -->
          <div class="space-y-4 sm:space-y-6">
            <div class="flex items-center gap-3 mb-4 sm:mb-6">
              <div class="w-8 h-8 sm:w-10 sm:h-10 bg-red-100 rounded-xl flex items-center justify-center">
                <Stethoscope class="w-4 h-4 sm:w-5 sm:h-5 text-red-600" />
              </div>
              <div>
                <h3 class="text-lg sm:text-xl font-semibold text-gray-900">Symptoms & Health History</h3>
                <p class="text-xs sm:text-sm text-gray-500">Record symptoms and medical history</p>
              </div>
            </div>
           
            <!-- Past Diagnosis -->
            <div>
              <label for="past-diagnosis" class="block text-xs sm:text-sm font-medium text-gray-700 mb-2">Past Diagnosis</label>
              <div class="relative">
                <input
                  id="past-diagnosis"
                  v-model="diagnosisSearch"
                  @input="filterDiagnoses"
                  @keydown.enter="addDiagnosisFromSearch"
                  @focus="handleDiagnosisFocus"
                  @blur="handleDiagnosisBlur"
                  type="text"
                  placeholder="Enter the past diagnosis"
                  class="w-full px-3 sm:px-4 py-2 sm:py-3 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-100 focus:border-blue-400 outline-none transition-all text-sm sm:text-base"
                />
               
                <!-- Enter hint -->
                <div v-if="diagnosisSearch && diagnosisSearch.trim() && !selectedDiagnoses.includes(diagnosisSearch.trim())"
                     class="absolute right-3 top-1/2 transform -translate-y-1/2 text-xs text-blue-600 bg-blue-50 px-2 py-1 rounded-lg border border-blue-200">
                  Press Enter to add
                </div>
                 
                  <!-- Diagnosis dropdown -->
                  <div v-if="showDiagnosisDropdown && filteredDiagnoses.length > 0" class="absolute z-10 w-full mt-1 bg-white border border-gray-200 rounded-lg shadow-lg max-h-48 overflow-y-auto">
                    <div
                      v-for="(diagnosis, index) in filteredDiagnoses"
                      :key="index"
                      @mousedown.prevent="addDiagnosis(diagnosis)"
                      class="px-4 py-3 hover:bg-gray-50 cursor-pointer text-sm transition-colors"
                      :class="{ 'bg-blue-50': diagnosisHighlightedIndex === index }"
                    >
                      {{ diagnosis }}
                    </div>
                  </div>
                </div>
               
               
              <!-- Selected diagnoses badges -->
              <div v-if="selectedDiagnoses.length > 0" class="flex flex-wrap gap-2 mt-3">
                <div
                  v-for="(diagnosis, index) in selectedDiagnoses"
                  :key="index"
                  class="inline-flex items-center px-2 sm:px-3 py-1 rounded-full text-xs sm:text-sm font-medium bg-blue-100 text-blue-800"
                >
                  {{ diagnosis }}
                  <button
                    @click="removeDiagnosis(index)"
                    class="ml-1 sm:ml-2 text-blue-600 hover:text-blue-800 focus:outline-none"
                    type="button"
                  >
                    <X size="14" class="sm:w-4 sm:h-4" />
                  </button>
                </div>
              </div>
            </div>
             
            <!-- Symptoms Section -->
            <div>
              <label class="block text-xs sm:text-sm font-medium text-gray-700 mb-3">Symptoms</label>
              <div class="border border-gray-200 rounded-lg">
                <div class="grid grid-cols-12 gap-2 bg-gray-50 p-3 sm:p-4 text-xs sm:text-sm font-medium text-gray-600">
                  <div class="col-span-5">Symptom</div>
                  <div class="col-span-3">Duration</div>
                  <div class="col-span-3">Severity</div>
                  <div class="col-span-1"></div>
                </div>
                 
                <div v-for="(symptom, index) in symptomEntries" :key="index" class="grid grid-cols-12 gap-2 p-3 sm:p-4 border-t border-gray-200">
                  <div class="col-span-5 relative">
                    <input
                      v-model="symptom.name"
                      @focus="showSymptomDropdown(index)"
                      @blur="handleSymptomRowBlur(index)"
                      @input="showSymptomDropdown(index)"
                      type="text"
                      placeholder="Select symptom"
                      class="w-full px-2 sm:px-3 py-1.5 sm:py-2 border border-gray-200 rounded-lg text-xs sm:text-sm focus:ring-2 focus:ring-blue-100 focus:border-blue-400 outline-none transition-all"
                    />
                     
                      <!-- Symptom dropdown -->
                      <div v-if="symptom.showDropdown && getFilteredSymptoms(symptom.name).length > 0" class="absolute z-50 w-full mt-1 bg-white border border-gray-200 rounded-lg shadow-xl max-h-48 overflow-y-auto">
                        <div
                          v-for="(option, optIndex) in getFilteredSymptoms(symptom.name)"
                          :key="optIndex"
                          @mousedown.prevent="selectSymptomForRow(option, index)"
                          class="px-4 py-3 hover:bg-gray-50 cursor-pointer text-sm transition-colors"
                        >
                          {{ option }}
                        </div>
                      </div>
                    </div>
                   
                  <div class="col-span-3">
                    <select
                      v-model="symptom.duration"
                      class="w-full px-2 sm:px-3 py-1.5 sm:py-2 border border-gray-200 rounded-lg text-xs sm:text-sm focus:ring-2 focus:ring-blue-100 focus:border-blue-400 outline-none transition-all appearance-none"
                    >
                      <option value="">Select</option>
                      <option value="< 24 hours">24 hours</option>
                      <option value="1-3 days">1-3 days</option>
                      <option value="3-7 days">3-7 days</option>
                      <option value="1-2 weeks">1-2 weeks</option>
                      <option value="2-4 weeks">2-4 weeks</option>
                      <option value="> 1 month">> 1 month</option>
                    </select>
                  </div>
                 
                  <div class="col-span-3">
                    <select
                      v-model="symptom.severity"
                      class="w-full px-2 sm:px-3 py-1.5 sm:py-2 border border-gray-200 rounded-lg text-xs sm:text-sm focus:ring-2 focus:ring-blue-100 focus:border-blue-400 outline-none transition-all appearance-none"
                    >
                      <option value="">Select</option>
                      <option value="Mild">Mild</option>
                      <option value="Moderate">Moderate</option>
                      <option value="Severe">Severe</option>
                    </select>
                  </div>
                 
                  <div class="col-span-1 flex justify-center items-center">
                    <button
                      @click="removeSymptomRow(index)"
                      class="text-gray-400 hover:text-red-500 focus:outline-none p-1 rounded transition-colors"
                      type="button"
                    >
                      <X size="14" class="sm:w-4 sm:h-4" />
                    </button>
                  </div>
                </div>
              </div>
               
              <button
                @click="addSymptomRow"
                class="mt-3 sm:mt-4 w-full flex items-center justify-center px-3 sm:px-4 py-2 sm:py-3 border border-dashed border-gray-300 rounded-lg text-blue-600 hover:bg-blue-50 hover:border-blue-400 transition-colors text-xs sm:text-sm font-medium"
              >
                <Plus size="14" class="mr-1 sm:mr-2 sm:w-4 sm:h-4" />
                Add Symptom
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
   
    <!-- Submit Button -->
    <div v-if="!predictionResult" class="mt-6">
      <button
        @click="submitPrediction"
        :disabled="isLoading || connectionStatus === false"
        class="w-full px-4 sm:px-6 py-3 sm:py-4 bg-gradient-to-r from-blue-500 to-emerald-500 text-white rounded-full hover:from-blue-600 hover:to-emerald-600 transition-all duration-300 flex items-center justify-center space-x-3 text-base sm:text-lg font-semibold disabled:opacity-50 disabled:cursor-not-allowed shadow-lg hover:shadow-xl"
      >
        <ActivityIcon v-if="isLoading" class="w-4 h-4 sm:w-5 sm:h-5 animate-spin" />
        <Zap v-else class="w-4 h-4 sm:w-5 sm:h-5" />
        <span>{{ isLoading ? 'Processing...' : 'Result' }}</span>
      </button>
    </div>
   
    <!-- Error Display -->
    <div v-if="error" class="mb-6 p-4 bg-red-50 border border-red-200 text-red-700 rounded-lg flex items-center gap-3">
      <AlertTriangle class="w-5 h-5 flex-shrink-0" />
      <span class="font-medium">{{ error }}</span>
    </div>
   
    <!-- Results Section -->
    <div v-if="predictionResult" class="bg-white rounded-lg border border-gray-200">
      <!-- Results Header -->
      <div class="p-4 sm:p-6 border-b border-gray-200">
        <div class="flex items-center gap-3 sm:gap-4">
          <div class="w-10 h-10 sm:w-12 sm:h-12 bg-green-100 rounded-xl flex items-center justify-center">
            <ClipboardCheck class="w-5 h-5 sm:w-6 sm:h-6 text-green-600" />
          </div>
          <div>
            <h2 class="text-lg sm:text-2xl font-bold text-gray-900">Assessment Results</h2>
            <p class="text-sm sm:text-base text-gray-600 mt-1">Health analysis for {{ patientData['Pet Name'] }}</p>
            <div class="flex flex-wrap gap-2 sm:gap-3 mt-2 text-xs sm:text-sm text-gray-500">
              <span class="px-2 py-1 bg-gray-100 rounded-full">{{ species.charAt(0).toUpperCase() + species.slice(1) }}</span>
              <span v-if="patientData.Breed" class="px-2 py-1 bg-gray-100 rounded-full">{{ patientData.Breed }}</span>
              <span v-if="patientData['Age (years)']" class="px-2 py-1 bg-gray-100 rounded-full">{{ patientData['Age (years)'] }} years</span>
              <span v-if="patientData['Weight (kg)']" class="px-2 py-1 bg-gray-100 rounded-full">{{ patientData['Weight (kg)'] }} kg</span>
            </div>
          </div>
        </div>
      </div>
     
      <!-- Results Content -->
      <div class="p-4 sm:p-6 space-y-4 sm:space-y-6">
        <!-- Predicted Diseases -->
        <div class="bg-gradient-to-br from-blue-50 to-blue-100 rounded-xl p-4 sm:p-6 border border-blue-200">
          <h3 class="flex items-center text-base sm:text-lg font-semibold text-gray-900 mb-3 sm:mb-4">
            <AlertCircle class="w-4 h-4 sm:w-5 sm:h-5 text-blue-600 mr-2 sm:mr-3" />
            Potential Health Conditions
          </h3>
              <div class="space-y-4">
            <div
                  v-for="(prediction, index) in predictionResult?.predictions || []"
              :key="index"
                  class="p-4 bg-white rounded-lg border shadow-sm"
                  :class="{'border-blue-300 bg-blue-50': index === 0, 'border-gray-200': index !== 0}"
            >
                  <div class="font-semibold text-gray-900 mb-3">{{ prediction.disease }}</div>
                  <div class="h-6 bg-gray-200 rounded-full overflow-hidden">
                <div
                      class="h-full rounded-full flex items-center justify-end pr-3 text-sm font-medium text-white"
                      :class="index === 0 ? 'bg-gradient-to-r from-blue-500 to-blue-600' : 'bg-gray-400'"
                  :style="{ width: `${prediction.probability * 100}%` }"
                >
                  {{ (prediction.probability * 100).toFixed(1) }}%
                </div>
              </div>
            </div>
          </div>
        </div>
       
        <!-- Recommended Diagnostics -->
        <div class="bg-gradient-to-br from-green-50 to-green-100 rounded-xl p-4 sm:p-6 border border-green-200">
          <h3 class="flex items-center text-base sm:text-lg font-semibold text-gray-900 mb-3 sm:mb-4">
            <Stethoscope class="w-4 h-4 sm:w-5 sm:h-5 text-green-600 mr-2 sm:mr-3" />
            Recommended Diagnostics
          </h3>
              <div class="space-y-3">
                <div
                  v-for="(diagnostic, index) in predictionResult?.report?.diagnostics || []"
              :key="index"
                  class="flex items-start gap-3 p-4 bg-white rounded-lg border border-gray-200 shadow-sm"
                >
                  <CheckCircle class="w-5 h-5 text-green-500 mt-0.5 flex-shrink-0" />
                  <span class="text-gray-700">{{ diagnostic }}</span>
                </div>
              </div>
        </div>
      </div>
     
      <!-- Reset Button -->
      <div class="p-4 sm:p-6 border-t border-gray-200">
        <button
          @click="resetForm"
          class="w-full px-4 sm:px-6 py-3 sm:py-4 bg-gradient-to-r from-gray-500 to-gray-600 text-white rounded-lg hover:from-gray-600 hover:to-gray-700 transition-all duration-300 flex items-center justify-center space-x-3 text-base sm:text-lg font-semibold shadow-lg hover:shadow-xl"
        >
          <RefreshCw class="w-4 h-4 sm:w-5 sm:h-5" />
          <span>New Assessment</span>
        </button>
      </div>
    </div>
  </div>
</template>


<script>
import MLInferenceService from '@/services/MLInferenceService';
import { usePetsStore } from '@/stores/modules/petsStore';
import { useAuthStore } from '@/stores/modules/authStore';
import {
  Info, PawPrint, ChevronRight, Stethoscope, Search, X,
  AlertTriangle, RefreshCw, Plus, Zap, ActivityIcon,
  ClipboardCheck, AlertCircle, CheckCircle
} from 'lucide-vue-next';


export default {
  name: 'VetHealthRiskAssessment',
  components: {
    Info,
    PawPrint,
    ChevronRight,
    Stethoscope,
    Search,
    X,
    AlertTriangle,
    RefreshCw,
    Plus,
    Zap,
    ActivityIcon,
    ClipboardCheck,
    AlertCircle,
    CheckCircle
  },
 
  data() {
    return {
      // Use the exact field names expected by the server
      patientData: {
        'Pet Name': '',
        'Age (years)': null,
        'Weight (kg)': null,
        'Breed': '',
        'Past Diagnosis': '',
        'Symptoms': '',
        'Vaccination_Status': 'unknown'
      },
      species: '',
      isLoading: false,
      connectionStatus: null,
      error: null,
      predictionResult: null,
      messageListener: null,
     
      // Pet suggestion functionality
      petsStore: null,
      authStore: null,
      availablePets: [],
      petSuggestions: [],
      showPetSuggestions: false,
      petSearchQuery: '',
      petAgeDisplay: '',
      selectedPetVaccinations: [],
     
      // Symptoms selection
      symptomSearch: '',
      selectedSymptoms: [],
      showSymptomsDropdown: false,
     
      // Symptom entries for tabular format
      symptomEntries: [
        { name: '', duration: '', severity: '', showDropdown: false }
      ],
     
      // Diagnosis selection
      diagnosisSearch: '',
      selectedDiagnoses: [],
      showDiagnosisDropdown: false,
      diagnosisHighlightedIndex: -1,
     
      // Common symptoms database
      commonSymptoms: [
        'Vomiting', 'Diarrhea', 'Lethargy', 'Loss of appetite', 'Weight loss',
        'Increased thirst', 'Increased urination', 'Coughing', 'Sneezing',
        'Difficulty breathing', 'Coughing', 'Itching', 'Hair loss', 'Fever',
        'Swelling', 'Discharge from eyes', 'Discharge from nose', 'Bad breath',
        'Seizures', 'Bleeding', 'Pale gums', 'Fever', 'Aggression',
        'Lameness', 'Depression', 'Excessive barking/meowing', 'Drooling'
      ],
     
      // Common diagnoses database - updated to include diagnoses for supported species only
      commonDiagnoses: [
        // Dog diagnoses
        'Canine Distemper', 'Canine Parvovirus', 'Kennel Cough', 'Canine Coronavirus',
        'Heartworm Disease', 'Ehrlichiosis', 'Leptospirosis', 'Mange', 'Patellar Luxation', 'Rabies',
       
        // Cat diagnoses
        'Feline Calicivirus', 'Feline Distemper', 'Feline Herpesvirus',
        'Feline Immunodeficiency Virus', 'Feline Infectious Peritonitis',
        'Feline Leukemia Virus', 'Feline Lower Urinary Tract Disease',
        'Feline Upper Respiratory Infection', 'Ringworm', 'Scabies',
       
        // Rabbit diagnoses
        'Coccidiosis', 'Flystrike', 'Gastrointestinal (GI) Stasis',
        'Malocclusion', 'Myxomatosis', 'Pasteurellosis', 'Pododermatitis',
        'Psoroptes cuniculi', 'Rabbit Hemorrhagic Disease', 'Uterine Adenocarcinoma',
       
        // Hamster diagnoses
        'Abscesses', 'Conjunctivitis', 'Diarrhea', 'Ectoparasitosis',
        'Heat Stroke', 'Malocclusion', 'Mange', 'Proliferative Ileitis',
        'Ringworm', 'Tyzzers Disease'
      ],
      // Breed lists by species
      dogBreeds: [
        'Aspin',
        'Shih Tzu',
        'Siberian Husky',
        'Chihuahua',
        'Labrador',
        'Beagle',
        'Golden Retriever',
        'Poodle',
        'German Shepherd',
        'Bulldog'
      ],
      catBreeds: [
        'Philippine Shorthair',
        'Persian Cat',
        'Siamese Cat',
        'Himalayan Cat',
        'Russian Blue Cat',
        'American Shorthair',
        'Exotic Shorthair',
        'Bengal Cat',
        'British Shorthair',
        'Maine Coon'
      ],
      hamsterBreeds: [
        'Syrian Hamster',
        'Dwarf Campbell Russian Hamster',
        'Winter White Russian Dwarf Hamster',
        'Roborovski Hamster',
        'Chinese Hamster',
        'Teddy Bear Hamster',
        'Black Bear Hamster',
        'European Hamster',
        'Robust Hamster',
        'Mangolian Hamster'
      ],
      rabbitBreeds: [
        'Mini Rex',
        'Holland Lop',
        'Dutch Rabbit',
        'Angora Rabbit',
        'Lionhead',
        'Miniature Lop',
        'Flemish Giant',
        'English Angora',
        'New Zealand Rabbit',
        'Himalayan Rabbit'
      ],
      filteredDiagnoses: [],
     
      // Form field weights for progress calculation
      formFieldWeights: {
        'petName': 20,
        'age': 15,
        'weight': 15,
        'breed': 10,
        'vaccinationStatus': 10,
        'symptoms': 30
      }
    };
  },
  computed: {
    breedOptions() {
      switch(this.species) {
        case 'dog':
          return this.dogBreeds;
        case 'cat':
          return this.catBreeds;
        case 'hamster':
          return this.hamsterBreeds;
        case 'rabbit':
          return this.rabbitBreeds;
        default:
          return [];
      }
    },
   
    // Calculate form completion percentage
    formCompletionPercentage() {
      let completionScore = 0;
     
      // Pet name (required)
      if (this.patientData['Pet Name']) {
        completionScore += this.formFieldWeights.petName;
      }
     
      // Age
      if (this.patientData['Age (years)'] !== null && this.patientData['Age (years)'] >= 0) {
        completionScore += this.formFieldWeights.age;
      }
     
      // Weight
      if (this.patientData['Weight (kg)'] !== null && this.patientData['Weight (kg)'] >= 0) {
        completionScore += this.formFieldWeights.weight;
      }
     
      // Breed
      if (this.patientData.Breed) {
        completionScore += this.formFieldWeights.breed;
      }
     
      // Vaccination status
      if (this.patientData['Vaccination_Status'] && this.patientData['Vaccination_Status'] !== 'unknown') {
        completionScore += this.formFieldWeights.vaccinationStatus;
      }
     
      // Symptoms (at least one symptom is required)
      const hasSymptom = this.symptomEntries.some(entry => entry.name.trim() !== '');
      const hasSymptomText = this.patientData.Symptoms.trim() !== '';
      const hasPastDiagnosis = this.selectedDiagnoses.length > 0;
     
      if (hasSymptom || hasSymptomText || hasPastDiagnosis) {
        // Calculate symptom completeness
        let symptomScore = 0;
       
        // Check for valid symptom entries
        const validSymptoms = this.symptomEntries.filter(entry => entry.name.trim() !== '');
        if (validSymptoms.length > 0) {
          // Calculate how many symptoms have duration and severity
          const completeSymptoms = validSymptoms.filter(entry => entry.duration && entry.severity);
          const partialSymptoms = validSymptoms.filter(entry => (entry.duration || entry.severity) && !(entry.duration && entry.severity));
         
          // Complete symptoms count more than partial ones
          symptomScore = (completeSymptoms.length * 1.0 + partialSymptoms.length * 0.5) / validSymptoms.length;
        }
       
        // Additional symptom text adds value
        if (hasSymptomText) {
          symptomScore = Math.max(symptomScore, 0.5);
        }
       
        // Past diagnosis adds value
        if (hasPastDiagnosis) {
          symptomScore = Math.max(symptomScore, 0.7);
        }
       
        // Apply the symptom weight
        completionScore += this.formFieldWeights.symptoms * symptomScore;
      }
     
      // Round to nearest integer
      return Math.round(completionScore);
    }
  },
 
  watch: {
    // Sync symptom entries with symptoms text area
    symptomEntries: {
      handler(newEntries) {
        const validEntries = newEntries.filter(entry => entry.name && (entry.duration || entry.severity));
        if (validEntries.length > 0) {
          const symptomText = validEntries.map(entry => {
            let text = entry.name;
            if (entry.duration) text += ` (Duration: ${entry.duration})`;
            if (entry.severity) text += ` (Severity: ${entry.severity})`;
            return text;
          }).join('; ');
         
          // Update the symptoms field while preserving any additional text
          const additionalText = this.patientData.Symptoms.replace(
            this.symptomEntries.map(e => e.name).filter(Boolean).join(', '),
            ''
          ).trim();
         
          this.patientData.Symptoms = symptomText + (additionalText ? '. ' + additionalText : '');
        }
      },
      deep: true
    },
   
    // Sync selected diagnoses with past diagnosis field
    selectedDiagnoses: {
      handler(newDiagnoses) {
        if (newDiagnoses.length > 0) {
          this.patientData['Past Diagnosis'] = newDiagnoses.join(', ');
        } else {
          this.patientData['Past Diagnosis'] = '';
        }
      },
      deep: true
    },
    species: {
      handler(newSpecies, oldSpecies) {
        // Reset breed when species changes
        this.patientData.Breed = '';
      }
    },
   
    // Watch for manual age input changes
    petAgeDisplay: {
      handler(newAge) {
        // Convert manual age input to years for backend
        this.patientData['Age (years)'] = this.convertAgeToYears(newAge);
      }
    }
  },
 
  async created() {
    // Initialize stores
    this.petsStore = usePetsStore();
    this.authStore = useAuthStore();
   
    // Load available pets for suggestions
    await this.loadAvailablePets();
   
    // Connect to WebSocket when component is created
    this.connectWebSocket();
   
    // Listen for connection changes
    this.unsubscribeConnection = MLInferenceService.onConnectionChange((status) => {
      this.connectionStatus = status;
    });
   
    // Initialize filtered diagnoses
    this.filteredDiagnoses = [...this.commonDiagnoses];
  },
 
  beforeUnmount() {
    // Clean up WebSocket connection
    if (this.unsubscribeConnection) {
      this.unsubscribeConnection();
    }
   
    // Remove message listener if exists
    if (this.messageListener) {
      this.messageListener();
    }
  },
 
  methods: {
    // Pet suggestion methods
    async loadAvailablePets() {
      try {
        // Get all pets from all users (for vet to see all pets)
        // We'll fetch from the pets collection directly
        const { collection, getDocs, doc, getDoc } = await import('firebase/firestore');
        const { db } = await import('@/firebase');
       
        // Fetch all pets from the pets collection
        const petsRef = collection(db, 'pets');
        const petsSnapshot = await getDocs(petsRef);
       
        this.availablePets = [];
       
        // Process pets and fetch owner names
        for (const docSnapshot of petsSnapshot.docs) {
          const petData = docSnapshot.data();
         
          // Create pet object with proper structure
          const pet = {
            id: docSnapshot.id,
            name: petData.name || '',
            species: petData.species || '',
            breed: petData.breed || '',
            ageYears: petData.ageYears || 0,
            ageMonths: petData.ageMonths || 0,
            ageWeeks: petData.ageWeeks || 0,
            weight: petData.weight || 0,
            gender: petData.gender || '',
            ownerId: petData.ownerId || '',
            photoURL: petData.photoURL || '',
            vaccinations: petData.vaccinations || [], // Include vaccination records
            // Include any other fields that might exist
            ...petData
          };
         
          // Fetch owner name if ownerId exists
          if (pet.ownerId) {
            try {
              const userDoc = await getDoc(doc(db, 'users', pet.ownerId));
              if (userDoc.exists()) {
                const userData = userDoc.data();
                pet.ownerName = userData.firstName && userData.lastName
                  ? `${userData.firstName} ${userData.lastName}`.trim()
                  : userData.displayName || userData.email || 'Unknown Owner';
              } else {
                pet.ownerName = 'Unknown Owner';
              }
            } catch (error) {
              pet.ownerName = 'Unknown Owner';
            }
          } else {
            pet.ownerName = 'No Owner';
          }
         
          this.availablePets.push(pet);
        }
       
      } catch (error) {
        this.availablePets = [];
      }
    },


    onPetNameInput(event) {
      this.petSearchQuery = event.target.value;
      this.patientData['Pet Name'] = event.target.value;
     
      // Always allow manual typing, but show suggestions if there are matches
      if (this.petSearchQuery.length > 0) {
        this.searchPets();
        // Only show suggestions if there are actual matches
        this.showPetSuggestions = this.petSuggestions.length > 0;
      } else {
        this.showPetSuggestions = false;
        this.petSuggestions = [];
      }
    },


    searchPets() {
      if (!this.petSearchQuery || this.petSearchQuery.length < 1) {
        this.petSuggestions = [];
        return;
      }


      const query = this.petSearchQuery.toLowerCase();
     
      this.petSuggestions = this.availablePets.filter(pet => {
        // Search by name, species, or breed
        const nameMatch = pet.name && pet.name.toLowerCase().includes(query);
        const speciesMatch = pet.species && pet.species.toLowerCase().includes(query);
        const breedMatch = pet.breed && pet.breed.toLowerCase().includes(query);
       
        return nameMatch || speciesMatch || breedMatch;
      }).slice(0, 5); // Limit to 5 suggestions
    },


    selectPet(pet) {
      this.patientData['Pet Name'] = pet.name;
      this.petSearchQuery = pet.name;
      this.showPetSuggestions = false;
     
      // Auto-fill pet information
      // Handle age - display in same format as Pets.vue
      this.petAgeDisplay = this.formatPetAgeForDisplay(pet);
     
      // Also set the age in years for backend compatibility (hidden field)
      let totalAgeInYears = 0;
      let hasValidAge = false;
     
      if (pet.ageYears && pet.ageYears > 0) {
        totalAgeInYears += pet.ageYears;
        hasValidAge = true;
      }
     
      if (pet.ageMonths && pet.ageMonths > 0) {
        totalAgeInYears += pet.ageMonths / 12;
        hasValidAge = true;
      }
     
      if (pet.ageWeeks && pet.ageWeeks > 0) {
        totalAgeInYears += pet.ageWeeks / 52;
        hasValidAge = true;
      }
     
      if (hasValidAge) {
        this.patientData['Age (years)'] = Math.round(totalAgeInYears * 100) / 100;
      }
     
      // Handle weight
      if (pet.weight !== undefined && pet.weight !== null && pet.weight > 0) {
        this.patientData['Weight (kg)'] = pet.weight;
      }
     
      // Handle species FIRST (this enables the breed dropdown)
      if (pet.species && pet.species.trim() !== '' && pet.species !== 'unknown' && pet.species !== 'Unspecified') {
        this.species = pet.species.toLowerCase();
      }
     
      // Handle breed AFTER species is set (so breed dropdown is enabled)
      if (pet.breed && pet.breed.trim() !== '' && pet.breed !== 'unknown' && pet.breed !== 'Unspecified') {
        // Use nextTick to ensure the breed dropdown is enabled before setting the value
        this.$nextTick(() => {
          const matchedBreed = this.findMatchingBreed(pet.breed, this.species);
          this.patientData['Breed'] = matchedBreed || pet.breed;
        });
      }
     
      // Handle vaccination status
      this.selectedPetVaccinations = pet.vaccinations || [];
      this.patientData['Vaccination_Status'] = this.determineVaccinationStatus(pet.vaccinations || []);
     
      // Clear suggestions
      this.petSuggestions = [];
    },


    hidePetSuggestions() {
      // Delay hiding to allow for click events
      setTimeout(() => {
        this.showPetSuggestions = false;
      }, 200);
    },


    // Helper function to format pet age like in Pets.vue
    formatPetAgeForDisplay(pet) {
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
     
      return ageParts.length > 0 ? ageParts.join(', ') : 'No age';
    },


    // Convert manual age input to years for backend
    convertAgeToYears(ageText) {
      if (!ageText || ageText.trim() === '') {
        return 0;
      }


      const text = ageText.toLowerCase();
      let totalYears = 0;


      // Extract years
      const yearMatch = text.match(/(\d+(?:\.\d+)?)\s*years?/);
      if (yearMatch) {
        totalYears += parseFloat(yearMatch[1]);
      }


      // Extract months
      const monthMatch = text.match(/(\d+(?:\.\d+)?)\s*months?/);
      if (monthMatch) {
        totalYears += parseFloat(monthMatch[1]) / 12;
      }


      // Extract weeks
      const weekMatch = text.match(/(\d+(?:\.\d+)?)\s*weeks?/);
      if (weekMatch) {
        totalYears += parseFloat(weekMatch[1]) / 52;
      }


      // If no specific units found, try to parse as just a number (assume years)
      if (totalYears === 0) {
        const numberMatch = text.match(/(\d+(?:\.\d+)?)/);
        if (numberMatch) {
          totalYears = parseFloat(numberMatch[1]);
        }
      }


      return Math.round(totalYears * 100) / 100; // Round to 2 decimal places
    },


    // Smart breed matching function
    findMatchingBreed(originalBreed, species) {
      if (!originalBreed || !species) return null;


      const breedOptions = this.breedOptions;
      const originalLower = originalBreed.toLowerCase().trim();


      // 1. Exact match (case insensitive)
      const exactMatch = breedOptions.find(breed =>
        breed.toLowerCase() === originalLower
      );
      if (exactMatch) {
        return exactMatch;
      }


      // 2. Partial match - check if original breed is contained in any option
      const partialMatch = breedOptions.find(breed =>
        breed.toLowerCase().includes(originalLower) ||
        originalLower.includes(breed.toLowerCase())
      );
      if (partialMatch) {
        return partialMatch;
      }


      // 3. Word-based matching - split by spaces and check individual words
      const originalWords = originalLower.split(/\s+/);
      const wordMatch = breedOptions.find(breed => {
        const breedWords = breed.toLowerCase().split(/\s+/);
        // Check if any word from original breed matches any word in breed option
        return originalWords.some(originalWord =>
          breedWords.some(breedWord =>
            breedWord.includes(originalWord) || originalWord.includes(breedWord)
          )
        );
      });
      if (wordMatch) {
        return wordMatch;
      }


      // 4. Fuzzy matching for common variations
      const fuzzyMatches = {
        // Cat breeds
        'persian': 'Persian Cat',
        'siamese': 'Siamese Cat',
        'himalayan': 'Himalayan Cat',
        'russian blue': 'Russian Blue Cat',
        'american shorthair': 'American Shorthair',
        'exotic shorthair': 'Exotic Shorthair',
        'bengal': 'Bengal Cat',
        'british shorthair': 'British Shorthair',
        'maine coon': 'Maine Coon',
        'philippine shorthair': 'Philippine Shorthair',
       
        // Dog breeds
        'aspin': 'Aspin',
        'shih tzu': 'Shih Tzu',
        'siberian husky': 'Siberian Husky',
        'chihuahua': 'Chihuahua',
        'labrador': 'Labrador',
        'beagle': 'Beagle',
        'golden retriever': 'Golden Retriever',
        'poodle': 'Poodle',
        'german shepherd': 'German Shepherd',
        'bulldog': 'Bulldog',
       
        // Add more fuzzy matches as needed
      };


      const fuzzyMatch = fuzzyMatches[originalLower];
      if (fuzzyMatch && breedOptions.includes(fuzzyMatch)) {
        return fuzzyMatch;
      }


      return null;
    },


    // Determine vaccination status based on vaccination records
    determineVaccinationStatus(vaccinations) {
      if (!vaccinations || vaccinations.length === 0) {
        return 'none'; // No vaccinations
      }


      // Check if vaccinations are up to date
      const now = new Date();
      const recentVaccinations = vaccinations.filter(vaccination => {
        if (!vaccination.date) return false;
       
        const vaccinationDate = vaccination.date.toDate ? vaccination.date.toDate() : new Date(vaccination.date);
        const daysSinceVaccination = (now - vaccinationDate) / (1000 * 60 * 60 * 24);
       
        // Consider vaccinations within the last 365 days as recent
        return daysSinceVaccination <= 365;
      });


      if (recentVaccinations.length === 0) {
        return 'none'; // All vaccinations are expired
      }


      // Check if all core vaccinations are up to date
      const coreVaccines = ['rabies', 'dhpp', 'dhppi', 'bordetella', 'feline', 'canine', 'core'];
      const hasCoreVaccines = recentVaccinations.some(vaccination => {
        const vaccineName = (vaccination.name || vaccination.vaccineName || '').toLowerCase();
        return coreVaccines.some(core => vaccineName.includes(core));
      });


      if (hasCoreVaccines && recentVaccinations.length >= 2) {
        return 'up-to-date'; // Has core vaccines and multiple recent vaccinations
      } else if (recentVaccinations.length > 0) {
        return 'partial'; // Has some vaccinations but may be missing core ones
      }


      return 'unknown';
    },


    // Format vaccination date for display
    formatVaccinationDate(date) {
      if (!date) return 'Unknown date';
     
      try {
        const vaccinationDate = date.toDate ? date.toDate() : new Date(date);
        const now = new Date();
        const daysSince = Math.floor((now - vaccinationDate) / (1000 * 60 * 60 * 24));
       
        if (daysSince === 0) return 'Today';
        if (daysSince === 1) return 'Yesterday';
        if (daysSince < 7) return `${daysSince} days ago`;
        if (daysSince < 30) return `${Math.floor(daysSince / 7)} weeks ago`;
        if (daysSince < 365) return `${Math.floor(daysSince / 30)} months ago`;
       
        return vaccinationDate.toLocaleDateString();
      } catch (error) {
        return 'Invalid date';
      }
    },


    // Symptom table methods
    addSymptomRow() {
      this.symptomEntries.push({ name: '', duration: '', severity: '', showDropdown: false });
    },
   
    removeSymptomRow(index) {
      this.symptomEntries.splice(index, 1);
      if (this.symptomEntries.length === 0) {
        this.addSymptomRow();
      }
    },
   
    showSymptomDropdown(index) {
      this.symptomEntries = this.symptomEntries.map((entry, i) => ({
        ...entry,
        showDropdown: i === index
      }));
    },
   
    handleSymptomRowBlur(index) {
      setTimeout(() => {
        if (this.symptomEntries[index]) {
          this.symptomEntries[index].showDropdown = false;
        }
      }, 200);
    },
   
    selectSymptomForRow(symptom, index) {
      this.symptomEntries[index].name = symptom;
      this.symptomEntries[index].showDropdown = false;
    },
   
    getFilteredSymptoms(searchTerm) {
      if (!searchTerm || searchTerm.trim() === '') {
        return this.commonSymptoms;
      }
     
      const search = searchTerm.toLowerCase();
      return this.commonSymptoms.filter(symptom =>
        symptom.toLowerCase().includes(search)
      );
    },
   
    // Diagnosis selection methods
    filterDiagnoses() {
      if (!this.diagnosisSearch.trim()) {
        this.filteredDiagnoses = [...this.commonDiagnoses];
        this.showDiagnosisDropdown = false; // Hide dropdown when search is empty
        return;
      }
     
      const search = this.diagnosisSearch.toLowerCase();
      this.filteredDiagnoses = this.commonDiagnoses.filter(
        diagnosis => diagnosis.toLowerCase().includes(search)
      );
     
      this.diagnosisHighlightedIndex = this.filteredDiagnoses.length > 0 ? 0 : -1;
      this.showDiagnosisDropdown = true; // Show dropdown when there's text and matches
    },
   
    addDiagnosis(diagnosis) {
      if (!this.selectedDiagnoses.includes(diagnosis)) {
        this.selectedDiagnoses.push(diagnosis);
        this.diagnosisSearch = '';
        this.showDiagnosisDropdown = false; // Hide dropdown immediately after selection
        this.filterDiagnoses();
      }
    },
   
    addDiagnosisFromSearch(event) {
      event.preventDefault();
     
      if (this.diagnosisHighlightedIndex >= 0 && this.filteredDiagnoses.length > 0) {
        this.addDiagnosis(this.filteredDiagnoses[this.diagnosisHighlightedIndex]);
      } else if (this.diagnosisSearch.trim() && !this.selectedDiagnoses.includes(this.diagnosisSearch.trim())) {
        // Add custom diagnosis if it doesn't exist in the list
        this.selectedDiagnoses.push(this.diagnosisSearch.trim());
        this.diagnosisSearch = '';
        this.showDiagnosisDropdown = false; // Hide dropdown after adding manual entry
        this.filterDiagnoses();
      }
    },
   
    removeDiagnosis(index) {
      this.selectedDiagnoses.splice(index, 1);
    },
   
    handleDiagnosisFocus() {
      // Show dropdown when focusing on the field if there's text
      if (this.diagnosisSearch && this.diagnosisSearch.trim()) {
        this.filterDiagnoses(); // This will show the dropdown if there are matches
      }
    },
   
    handleDiagnosisBlur() {
      // Delay hiding dropdown to allow click events to complete
      setTimeout(() => {
        this.showDiagnosisDropdown = false;
      }, 200);
    },
   
    // Legacy symptom selection methods (kept for compatibility)
    showAllSymptoms() {
      this.showSymptomsDropdown = true;
    },
   
    addSymptom(symptom) {
      if (!this.selectedSymptoms.includes(symptom)) {
        this.selectedSymptoms.push(symptom);
        this.symptomSearch = '';
      }
    },
   
    removeSymptom(index) {
      this.selectedSymptoms.splice(index, 1);
    },
   
    handleSymptomBlur() {
      // Delay hiding dropdown to allow click events to complete
      setTimeout(() => {
        this.showSymptomsDropdown = false;
      }, 200);
    },
   
    async connectWebSocket() {
      try {
        await MLInferenceService.connect();
      } catch (error) {
        console.error('Failed to connect to ML service:', error);
        this.error = 'Failed to connect to the prediction server. Please try again later.';
      }
    },
   
    async reconnectWebSocket() {
      this.error = null;
      try {
        await MLInferenceService.connect();
      } catch (error) {
        this.error = 'Failed to reconnect. Please try again later.';
      }
    },
   
    async submitPrediction() {
      if (!this.validateForm()) {
        return;
      }
     
      this.isLoading = true;
      this.error = null;
     
      // Format symptom data for the backend
      const symptomData = {};
      this.symptomEntries.forEach((entry, index) => {
        if (entry.name) {
          const num = index + 1;
          symptomData[`Symptom ${num}`] = entry.name;
          symptomData[`Symptom ${num}_Duration`] = entry.duration || '';
          symptomData[`Symptom ${num}_Severity`] = entry.severity || '';
        }
      });
     
      // Format patient data for the backend - use the exact field names expected by the server
      const formattedData = {
        patient_data: {
          'Pet Name': this.patientData['Pet Name'],
          'Age (years)': this.patientData['Age (years)'],
          'Weight (kg)': this.patientData['Weight (kg)'],
          'Breed': this.patientData.Breed,
          'Past Diagnosis': this.patientData['Past Diagnosis'],
          'Symptoms': this.patientData.Symptoms,
          'Treatment': this.patientData.Treatment,
          'Vaccination_Status': this.patientData['Vaccination_Status'],
          ...symptomData
        },
        species: this.species
      };
     
     
     
      // Set up message listener
      if (this.messageListener) {
        this.messageListener(); // Remove previous listener
      }
     
      this.messageListener = MLInferenceService.onMessage((data) => {
        this.isLoading = false;
       
        if (data.error) {
          this.error = data.error;
        } else {
          this.predictionResult = data;
        }
      });
     
      try {
        // Send the message
        await MLInferenceService.sendMessage(formattedData);
      } catch (error) {
        this.isLoading = false;
        this.error = `Error: ${error.message}`;
        console.error('Error sending prediction request:', error);
      }
    },
   
    validateForm() {
      // Reset previous errors
      this.error = null;
     
      // Basic validation
      if (!this.patientData['Pet Name']) {
        this.error = 'Please enter a pet name';
        return false;
      }
     
      if (this.patientData['Age (years)'] === null || this.patientData['Age (years)'] < 0) {
        this.error = 'Please enter a valid age';
        return false;
      }
     
      if (this.patientData['Weight (kg)'] === null || this.patientData['Weight (kg)'] < 0) {
        this.error = 'Please enter a valid weight';
        return false;
      }
     
      // Check if at least one symptom is entered
      const hasSymptom = this.symptomEntries.some(entry => entry.name.trim() !== '');
      if (!hasSymptom && !this.patientData.Symptoms) {
        this.error = 'Please enter at least one symptom';
        return false;
      }
     
      return true;
    },
   
    resetForm() {
      this.predictionResult = null;
      this.error = null;
      this.selectedSymptoms = [];
      this.symptomSearch = '';
      this.selectedDiagnoses = [];
      this.diagnosisSearch = '';
      this.symptomEntries = [{ name: '', duration: '', severity: '', showDropdown: false }];
     
      // Reset form fields but keep the species selection
      this.patientData = {
        'Pet Name': '',
        'Age (years)': null,
        'Weight (kg)': null,
        'Breed': '',
        'Past Diagnosis': '',
        'Symptoms': '',
        'Treatment': '',
        'Vaccination_Status': 'unknown'
      };
     
      // Reset pet suggestion state
      this.petSearchQuery = '';
      this.showPetSuggestions = false;
      this.petSuggestions = [];
      this.petAgeDisplay = '';
      this.selectedPetVaccinations = [];
    }
  }
};
</script>


<style scoped>
/* Minimal custom styles - most styling now handled by Tailwind classes */
.animate-spin {
  animation: spin 1s linear infinite;
}


@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
</style>



