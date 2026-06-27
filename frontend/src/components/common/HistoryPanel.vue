<!-- components/common/HistoryPanel.vue -->
<template>
    <Transition 
      name="slide-fade"
      enter-active-class="transition-all duration-300 ease-out"
      leave-active-class="transition-all duration-300 ease-in"
      enter-from-class="opacity-0 transform -translate-x-5"
      leave-to-class="opacity-0 transform -translate-x-5"
    >
      <div 
        v-if="isVisible"
        class="bg-white overflow-hidden z-30 transition-all duration-300 ease-in-out flex flex-col fixed"
        :class="[
          isMobileView 
            ? 'inset-0 -mt-1 pb-20' 
            : 'left-20 top-4 h-[calc(100vh-2rem)] w-[400px] border border-gray-100 rounded-2xl shadow-sm'
        ]"
      >
        <!-- History Header -->
        <div :class="[isMobileView ? 'p-4' : 'p-6']">
          <div :class="['flex justify-between items-center', isMobileView ? 'mb-3' : 'mb-4']">
            <h2 :class="['font-semibold', isMobileView ? 'text-lg' : 'text-xl']">Appointment History</h2>
            <button 
              v-if="isMobileView"
              @click="closeHistory" 
              class="text-gray-500 hover:text-gray-700"
            >
              <XIcon :class="[isMobileView ? 'w-5 h-5' : 'w-6 h-6']" />
            </button>
          </div>
        </div>
    
        <!-- History Content -->
        <div :class="['overflow-y-auto flex-grow', isMobileView ? 'px-4' : 'px-6']">
          <div class="flex justify-between items-center mb-3">
            <h3 :class="['font-semibold', isMobileView ? 'text-xs' : 'text-sm']">Recent Appointments</h3>
            <div class="text-xs text-gray-500">
              {{ appointments.length }} appointment{{ appointments.length !== 1 ? 's' : '' }}
            </div>
          </div>
          
          <!-- Loading state with skeleton -->
          <div v-if="loading" class="space-y-3">
            <!-- Skeleton appointment cards -->
            <div v-for="i in 3" :key="i" :class="['rounded-lg border border-gray-100', isMobileView ? 'p-2.5' : 'p-3']">
              <!-- Header skeleton -->
              <div class="flex justify-between items-start mb-1">
                <div :class="['bg-gray-200 rounded animate-pulse', isMobileView ? 'h-3 w-24' : 'h-4 w-32']"></div>
                <div :class="['bg-gray-200 rounded-full animate-pulse', isMobileView ? 'h-4 w-16' : 'h-5 w-20']"></div>
              </div>
              
              <!-- Doctor name skeleton -->
              <div :class="['bg-gray-200 rounded animate-pulse mb-1', isMobileView ? 'h-3 w-28' : 'h-4 w-36']"></div>
              
              <!-- Pet name skeleton -->
              <div :class="['bg-gray-200 rounded animate-pulse mb-1', isMobileView ? 'h-3 w-20' : 'h-4 w-24']"></div>
              
              <!-- Date and time skeleton -->
              <div class="flex justify-between mb-1">
                <div :class="['bg-gray-200 rounded animate-pulse', isMobileView ? 'h-3 w-16' : 'h-4 w-20']"></div>
                <div :class="['bg-gray-200 rounded animate-pulse', isMobileView ? 'h-3 w-12' : 'h-4 w-16']"></div>
              </div>
              
              <!-- Created date skeleton -->
              <div :class="['bg-gray-200 rounded animate-pulse', isMobileView ? 'h-2 w-24' : 'h-3 w-32']"></div>
              
              <!-- Feedback status skeleton -->
              <div :class="['mt-1', isMobileView ? 'mt-0.5' : 'mt-1']">
                <div :class="['bg-gray-200 rounded-full animate-pulse', isMobileView ? 'h-4 w-20' : 'h-5 w-24']"></div>
              </div>
              
              <!-- Action buttons skeleton -->
              <div :class="['pt-2 border-t border-gray-100 flex justify-end', isMobileView ? 'mt-2' : 'mt-3']">
                <div :class="['bg-gray-200 rounded-full animate-pulse', isMobileView ? 'h-6 w-6' : 'h-8 w-8']"></div>
              </div>
            </div>
          </div>
          
          <!-- Error state -->
          <div v-else-if="error" :class="['bg-red-50 text-red-600 rounded-lg text-center', isMobileView ? 'p-3' : 'p-4']">
            <AlertCircleIcon :class="['mx-auto mb-2', isMobileView ? 'w-5 h-5' : 'w-6 h-6']" />
            <p>{{ error }}</p>
            <button 
              @click="() => fetchUserAppointments(true)" 
              :class="['mt-2 bg-red-100 hover:bg-red-200 text-red-700 rounded-full', isMobileView ? 'text-xs px-2 py-0.5' : 'text-sm px-3 py-1']"
            >
              Try Again
            </button>
          </div>
          
          <!-- Appointments list -->
          <div v-else-if="appointments.length > 0">
            <div 
              v-for="(appointment, index) in appointments" 
              :key="appointment.id"
              :class="['rounded-lg hover:bg-gray-50 border border-gray-100', isMobileView ? 'mb-2 p-2.5' : 'mb-3 p-3']"
            >
              <div class="flex justify-between items-start mb-1">
                <div :class="['font-medium', isMobileView ? 'text-sm' : '']">
                  {{ appointment.serviceNames && appointment.serviceNames.length > 0 
                    ? appointment.serviceNames[0] 
                    : 'Unnamed Service' }}
                </div>
                <span :class="getStatusClass(appointment)">
                  {{ isExpired(appointment) ? 'Expired' : formatStatus(getEffectiveStatus(appointment)) }}
                </span>
              </div>
              <div :class="['text-gray-700 mb-1', isMobileView ? 'text-xs' : 'text-sm']">
                <span>{{ appointment.doctorName || 'Unknown Doctor' }}</span>
              </div>
              <div :class="['text-gray-700 mb-1', isMobileView ? 'text-xs' : 'text-sm']">
                <span>Pet: {{ getPetDisplayName(appointment) }}</span>
              </div>
              <div :class="['text-gray-500 flex justify-between', isMobileView ? 'text-xs' : 'text-sm']">
                <span>{{ formatDate(appointment.date) }}</span>
                <span>{{ appointment.time }}</span>
              </div>
              
              <!-- Created date -->
              <div :class="['text-gray-400', isMobileView ? 'text-xs mt-0.5' : 'text-xs mt-1']">
                Created: {{ formatDateTime(appointment.createdAt) }}
              </div>
              

              
              <!-- Feedback status indicator -->
              <div v-if="getEffectiveStatus(appointment) === 'completed'" :class="[isMobileView ? 'text-xs mt-0.5' : 'text-xs mt-1']">
                <span 
                  v-if="appointment.hasFeedback" 
                  :class="['inline-flex items-center gap-1 bg-green-100 text-green-700 rounded-full', isMobileView ? 'px-1.5 py-0.5' : 'px-2 py-1']"
                >
                  <svg :class="[isMobileView ? 'w-2.5 h-2.5' : 'w-3 h-3']" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                  </svg>
                  Feedback Submitted
                </span>
                <span 
                  v-else 
                  :class="['inline-flex items-center gap-1 bg-blue-100 text-blue-700 rounded-full', isMobileView ? 'px-1.5 py-0.5' : 'px-2 py-1']"
                >
                  <svg :class="[isMobileView ? 'w-2.5 h-2.5' : 'w-3 h-3']" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-11a1 1 0 10-2 0v2H7a1 1 0 100 2h2v2a1 1 0 102 0v-2h2a1 1 0 100-2h-2V7z" clip-rule="evenodd"></path>
                  </svg>
                  Feedback Pending
                </span>
              </div>
              
              <!-- Action buttons -->
              <div :class="['pt-2 border-t border-gray-100 flex justify-end', isMobileView ? 'mt-2' : 'mt-3']">
                <!-- Three-dot menu button - only show for appointments with actionable statuses -->
                <div v-if="hasActionableOptions(appointment)" class="relative action-menu-container">
                  <button 
                    @click="toggleActionMenu(appointment.id)"
                    :class="['text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-full transition-colors duration-200', isMobileView ? 'p-1.5' : 'p-2']"
                    :title="'Actions for ' + (getPetDisplayName(appointment) || 'appointment')"
                  >
                    <svg :class="[isMobileView ? 'w-3.5 h-3.5' : 'w-4 h-4']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z"></path>
                    </svg>
                  </button>
                  
                  <!-- Dropdown menu -->
                  <div 
                    v-if="openActionMenu === appointment.id"
                    :class="[
                      'absolute right-0 bg-white rounded-lg shadow-lg border border-gray-200 z-20 overflow-hidden',
                      'backdrop-blur-sm bg-white/95',
                      'w-auto min-w-max max-w-xs',
                      // Open upward for last item, downward for others
                      index === appointments.length - 1 ? 'bottom-full mb-2' : 'top-full mt-2'
                    ]"
                    style="box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);"
                  >
                    <!-- Cancel option for pending appointments -->
                    <button 
                      v-if="getEffectiveStatus(appointment) === 'pending'"
                      @click="confirmCancel(appointment)"
                      :class="[
                        'w-full text-left text-red-600 hover:bg-red-50 flex items-center gap-2 transition-all duration-200',
                        'hover:shadow-sm border-l-2 border-transparent hover:border-red-200 whitespace-nowrap',
                        isMobileView ? 'px-2.5 py-2 text-xs' : 'px-3 py-2 text-sm'
                      ]"
                    >
                      <svg :class="[isMobileView ? 'w-3.5 h-3.5' : 'w-4 h-4']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                      </svg>
                      Cancel Appointment
                    </button>
                    
                    <!-- Create New Appointment option for reschedule requests -->
                    <button 
                      v-if="getEffectiveStatus(appointment) === 'consider_rescheduling'"
                      @click="createNewAppointment(appointment)"
                      :class="[
                        'w-full text-left text-orange-600 hover:bg-orange-50 flex items-center gap-2 transition-all duration-200',
                        'hover:shadow-sm border-l-2 border-transparent hover:border-orange-200 whitespace-nowrap',
                        isMobileView ? 'px-2.5 py-2 text-xs' : 'px-3 py-2 text-sm'
                      ]"
                    >
                      <svg :class="[isMobileView ? 'w-3.5 h-3.5' : 'w-4 h-4']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                      </svg>
                      Create New Appointment
                    </button>
                    
                    <!-- Create New Appointment option for reschedule requested status -->
                    <button 
                      v-if="getEffectiveStatus(appointment) === 'reschedule_requested'"
                      @click="createNewAppointment(appointment)"
                      :class="[
                        'w-full text-left text-orange-600 hover:bg-orange-50 flex items-center gap-2 transition-all duration-200',
                        'hover:shadow-sm border-l-2 border-transparent hover:border-orange-200 whitespace-nowrap',
                        isMobileView ? 'px-2.5 py-2 text-xs' : 'px-3 py-2 text-sm'
                      ]"
                    >
                      <svg :class="[isMobileView ? 'w-3.5 h-3.5' : 'w-4 h-4']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                      </svg>
                      Create New Appointment
                    </button>
                    
                    <!-- Create New Appointment option for reschedule approved status -->
                    <button 
                      v-if="getEffectiveStatus(appointment) === 'reschedule_approved'"
                      @click="createNewAppointment(appointment)"
                      :class="[
                        'w-full text-left text-blue-600 hover:bg-blue-50 flex items-center gap-2 transition-all duration-200',
                        'hover:shadow-sm border-l-2 border-transparent hover:border-blue-200 whitespace-nowrap',
                        isMobileView ? 'px-2.5 py-2 text-xs' : 'px-3 py-2 text-sm'
                      ]"
                    >
                      <svg :class="[isMobileView ? 'w-3.5 h-3.5' : 'w-4 h-4']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                      </svg>
                      Create New Appointment
                    </button>
                    
                    <!-- Create New Appointment option for reschedule request sent status -->
                    <button 
                      v-if="getEffectiveStatus(appointment) === 'reschedule_request_sent'"
                      @click="createNewAppointment(appointment)"
                      :class="[
                        'w-full text-left text-orange-600 hover:bg-orange-50 flex items-center gap-2 transition-all duration-200',
                        'hover:shadow-sm border-l-2 border-transparent hover:border-orange-200 whitespace-nowrap',
                        isMobileView ? 'px-2.5 py-2 text-xs' : 'px-3 py-2 text-sm'
                      ]"
                    >
                      <svg :class="[isMobileView ? 'w-3.5 h-3.5' : 'w-4 h-4']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                      </svg>
                      Create New Appointment
                    </button>
                    
                    <!-- View Notes option for completed appointments -->
                    <button 
                      v-if="getEffectiveStatus(appointment) === 'completed' && appointment.completionData"
                      @click="viewAppointmentSummary(appointment)"
                      :class="[
                        'w-full text-left text-purple-600 hover:bg-purple-50 flex items-center gap-2 transition-all duration-200',
                        'hover:shadow-sm border-l-2 border-transparent hover:border-purple-200 whitespace-nowrap',
                        isMobileView ? 'px-2.5 py-2 text-xs' : 'px-3 py-2 text-sm'
                      ]"
                    >
                      <svg :class="[isMobileView ? 'w-3.5 h-3.5' : 'w-4 h-4']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                      </svg>
                      View Notes
                    </button>
                    
                    <!-- View Prescription option for completed appointments -->
                    <button 
                      v-if="getEffectiveStatus(appointment) === 'completed' && appointment.completionData && appointment.completionData.prescription"
                      @click="viewPrescription(appointment)"
                      :class="[
                        'w-full text-left text-red-600 hover:bg-red-50 flex items-center gap-2 transition-all duration-200',
                        'hover:shadow-sm border-l-2 border-transparent hover:border-red-200 whitespace-nowrap',
                        isMobileView ? 'px-2.5 py-2 text-xs' : 'px-3 py-2 text-sm'
                      ]"
                    >
                      <svg :class="[isMobileView ? 'w-3.5 h-3.5' : 'w-4 h-4']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                      </svg>
                      View Prescription
                    </button>
                    
                    <!-- Download Prescription option for completed appointments -->
                    <button 
                      v-if="getEffectiveStatus(appointment) === 'completed' && appointment.completionData && appointment.completionData.prescription"
                      @click="downloadPrescription(appointment)"
                      :disabled="isGeneratingPDF"
                      :class="[
                        'w-full text-left flex items-center gap-2 transition-all duration-200',
                        'hover:shadow-sm border-l-2 border-transparent whitespace-nowrap',
                        isMobileView ? 'px-2.5 py-2 text-xs' : 'px-3 py-2 text-sm',
                        isGeneratingPDF 
                          ? 'text-gray-400 cursor-not-allowed' 
                          : 'text-green-600 hover:bg-green-50 hover:border-green-200'
                      ]"
                    >
                      <svg v-if="isGeneratingPDF" :class="[isMobileView ? 'w-3.5 h-3.5' : 'w-4 h-4', 'animate-spin']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                      </svg>
                      <svg v-else :class="[isMobileView ? 'w-3.5 h-3.5' : 'w-4 h-4']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                      </svg>
                      {{ isGeneratingPDF ? 'Generating PDF...' : 'Download Prescription' }}
                    </button>
                
                    <!-- Print Prescription option for completed appointments -->
                <button 
                      v-if="getEffectiveStatus(appointment) === 'completed' && appointment.completionData && appointment.completionData.prescription"
                      @click="printPrescription(appointment)"
                      :class="[
                        'w-full text-left text-purple-600 hover:bg-purple-50 flex items-center gap-2 transition-all duration-200',
                        'hover:shadow-sm border-l-2 border-transparent hover:border-purple-200 whitespace-nowrap',
                        isMobileView ? 'px-2.5 py-2 text-xs' : 'px-3 py-2 text-sm'
                      ]"
                >
                      <svg :class="[isMobileView ? 'w-3.5 h-3.5' : 'w-4 h-4']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"></path>
                      </svg>
                      Print Prescription
                </button>
                
                    <!-- Feedback option for completed appointments -->
                    <button 
                      v-if="getEffectiveStatus(appointment) === 'completed'"
                  @click="openFeedback(appointment)"
                  :class="[
                    'w-full text-left flex items-center gap-2 transition-all duration-200',
                    'hover:shadow-sm border-l-2 border-transparent whitespace-nowrap',
                    isMobileView ? 'px-2.5 py-2 text-xs' : 'px-3 py-2 text-sm',
                    appointment.hasFeedback 
                      ? 'text-green-600 hover:bg-green-50 hover:border-green-200' 
                      : 'text-blue-600 hover:bg-blue-50 hover:border-blue-200'
                  ]"
                    >
                      <svg :class="[isMobileView ? 'w-3.5 h-3.5' : 'w-4 h-4']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"></path>
                      </svg>
                      {{ appointment.hasFeedback ? 'View Feedback' : 'Leave Feedback' }}
                    </button>
                
                  </div>
                </div>
              </div>
            </div>
          </div>
          
          <!-- Empty state -->
          <div v-else :class="['flex flex-col items-center justify-center', isMobileView ? 'py-6' : 'py-10']">
            <CalendarIcon :class="['text-gray-300 mb-3', isMobileView ? 'w-8 h-8' : 'w-12 h-12']" />
            <div :class="['text-gray-500 text-center', isMobileView ? 'text-xs' : 'text-sm']">
              <h3 :class="['font-medium text-gray-900 mb-2', isMobileView ? 'text-base' : 'text-lg']">No Appointments</h3>
              <p>You haven't made any appointments yet. Your appointment history will appear here.</p>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  
    <!-- Confirmation Modal -->
    <div 
      v-if="showCancelModal" 
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-2 sm:p-4"
      @click.self="closeCancelModal"
    >
      <div class="bg-white rounded-xl shadow-xl p-3 sm:p-6 max-w-sm sm:max-w-md w-full">
        <div class="flex flex-col items-center text-center">
          <div class="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center mb-4">
            <AlertTriangleIcon class="w-6 h-6 text-red-600" />
          </div>
          <h2 class="text-lg sm:text-xl font-bold text-gray-900 mb-2">Cancel Appointment?</h2>
          <p class="text-sm sm:text-base text-gray-600 mb-4">
            Are you sure you want to cancel your appointment on 
            <span class="font-medium">{{ selectedAppointment ? formatDate(selectedAppointment.date) : '' }}</span> 
            at <span class="font-medium">{{ selectedAppointment ? selectedAppointment.time : '' }}</span>?
          </p>
          
          <!-- Cancellation Reason Input -->
          <div class="w-full mb-4">
            <label for="cancellation-reason" class="block text-left text-sm font-medium text-gray-700 mb-1">
              Please provide a reason for cancellation:
            </label>
            <textarea
              id="cancellation-reason"
              v-model="cancellationReason"
              rows="3"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500 text-sm"
              placeholder="Enter your reason for cancelling this appointment..."
              required
            ></textarea>
            <p v-if="reasonError" class="mt-1 text-left text-xs text-red-600">
              {{ reasonError }}
            </p>
          </div>
          
          <div class="flex flex-col sm:flex-row gap-3 w-full">
            <button 
              @click="closeCancelModal" 
              class="flex-1 py-1.5 sm:py-2 px-3 sm:px-4 rounded-full bg-red-200 text-red-800 hover:bg-red-300 transition-colors text-xs sm:text-sm"
            >
              No, Keep It
            </button>
            <button 
              @click="cancelAppointment" 
              :disabled="cancelLoading || !cancellationReason.trim()"
              class="flex-1 py-1.5 sm:py-2 px-3 sm:px-4 rounded-full bg-blue-500 text-white hover:bg-blue-700 transition-colors text-xs sm:text-sm disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span v-if="cancelLoading">Cancelling...</span>
              <span v-else>Yes, Cancel</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Feedback Modal -->
    <div 
      v-if="showFeedbackModal" 
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-2 sm:p-4"
      @click.self="closeFeedbackModal"
    >
      <div class="bg-white rounded-xl shadow-xl max-w-sm sm:max-w-2xl w-full max-h-[95vh] sm:max-h-[90vh] overflow-hidden">
        <div class="p-3 sm:p-6 overflow-y-auto max-h-[calc(95vh-3rem)] sm:max-h-[calc(90vh-3rem)]">
          <div class="flex justify-between items-center mb-4">
            <h2 class="text-lg sm:text-xl font-bold text-gray-900">Appointment Feedback</h2>
          </div>
          <div class="feedback-content">
          <AppointmentFeedback 
            :appointment="selectedAppointment" 
            @close="closeFeedbackModal"
            @feedback-submitted="onFeedbackSubmitted"
          />
          </div>
        </div>
      </div>
    </div>

         

    <!-- Appointment Summary Modal -->
    <div 
      v-if="showSummaryModal" 
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-2 sm:p-4"
      @click.self="closeSummaryModal"
    >
      <div class="bg-white rounded-xl shadow-xl max-w-sm sm:max-w-4xl w-full max-h-[95vh] sm:max-h-[90vh] overflow-hidden">
        <div class="p-4 sm:p-6 overflow-y-auto max-h-[calc(95vh-3rem)] sm:max-h-[calc(90vh-3rem)]">
          <div class="flex justify-between items-center mb-4">
            <h2 class="text-lg sm:text-xl font-bold text-gray-900">Appointment Summary</h2>
          </div>
          
          <!-- Appointment Details Header -->
          <div class="bg-gray-50 rounded-lg p-4 mb-6">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <h3 class="text-lg font-semibold text-gray-900 mb-2">
                  {{ selectedAppointment?.serviceNames && selectedAppointment.serviceNames.length > 0 
                    ? selectedAppointment.serviceNames.join(', ') 
                    : 'Appointment' }}
                </h3>
                <div class="space-y-1 text-sm text-gray-600">
                  <div><strong>Doctor:</strong> {{ selectedAppointment?.doctorName }}</div>
                  <div><strong>Pet:</strong> {{ getPetDisplayName(selectedAppointment) }}</div>
                  <div><strong>Date:</strong> {{ selectedAppointment ? formatDate(selectedAppointment.date) : '' }}</div>
                  <div><strong>Time:</strong> {{ selectedAppointment?.time }}</div>
                  <div><strong>Status:</strong> <span class="text-green-600 font-medium">Completed</span></div>
                </div>
              </div>
              <div class="flex items-center justify-center">
                <div class="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center">
                  <svg class="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                  </svg>
                </div>
              </div>
            </div>
          </div>

          <!-- Completion Summary Content -->
          <div v-if="selectedAppointment?.completionData" class="space-y-6">
            <!-- Services Summary -->
            <div v-if="selectedAppointment.completionData.services && selectedAppointment.completionData.services.length > 0">
              <h4 class="text-lg font-semibold text-gray-900 mb-3 flex items-center gap-2">
                <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                </svg>
                Services Completed
              </h4>
              <div class="space-y-3">
                <div v-for="(service, index) in selectedAppointment.completionData.services" :key="index" class="bg-blue-50 rounded-lg p-4 border border-blue-100">
                  <div class="flex items-center justify-between mb-2">
                    <span class="text-base font-medium text-blue-800">{{ service.name || `Service ${index + 1}` }}</span>
                    <span class="text-xs text-blue-600 capitalize bg-blue-100 px-2 py-1 rounded-full">{{ service.status?.replace('_', ' ') || 'completed' }}</span>
                  </div>
                  <div v-if="service.duration" class="text-sm text-blue-600 mb-2">Duration: {{ service.duration }} minutes</div>
                  <div v-if="service.notes" class="text-sm text-blue-700 bg-white rounded p-3 border border-blue-200">
                    {{ service.notes }}
                  </div>
                </div>
              </div>
            </div>
            
            <!-- Pet Health Assessment -->
            <div v-if="selectedAppointment.completionData.pets && selectedAppointment.completionData.pets.length > 0">
              <h4 class="text-lg font-semibold text-gray-900 mb-3 flex items-center gap-2">
                <svg class="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"></path>
                </svg>
                Health Assessment
              </h4>
              <div class="space-y-3">
                <div v-for="(pet, index) in selectedAppointment.completionData.pets" :key="index" class="bg-green-50 rounded-lg p-4 border border-green-100">
                  <div class="flex items-center justify-between mb-2">
                    <span class="text-base font-medium text-green-800">{{ pet.name || `Pet ${index + 1}` }}</span>
                    <span class="text-xs text-green-600 capitalize bg-green-100 px-2 py-1 rounded-full">{{ pet.overallHealth || 'assessed' }}</span>
                  </div>
                  <div v-if="pet.weight" class="text-sm text-green-600 mb-2">Weight: {{ pet.weight }} kg</div>
                  <div v-if="pet.healthNotes" class="text-sm text-green-700 bg-white rounded p-3 border border-green-200">
                    {{ pet.healthNotes }}
                  </div>
                  <div v-if="pet.followUpRequired" class="mt-3 p-3 bg-orange-50 rounded-lg border border-orange-200">
                    <div class="flex items-center gap-2 mb-2">
                      <span class="text-sm font-medium text-orange-700">Follow-up Required:</span>
                      <span class="text-xs text-orange-600 bg-orange-100 px-2 py-1 rounded-full">Yes</span>
                    </div>
                    <div v-if="pet.followUpNotes" class="text-sm text-orange-700">
                      {{ pet.followUpNotes }}
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- General Notes -->
            <div v-if="selectedAppointment.completionData.generalNotes" class="space-y-4">
              <h4 class="text-lg font-semibold text-gray-900 mb-3 flex items-center gap-2">
                <svg class="w-5 h-5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                </svg>
                Additional Notes
              </h4>
              
              <div v-if="selectedAppointment.completionData.generalNotes.treatmentSummary" class="bg-purple-50 rounded-lg p-4 border border-purple-100">
                <div class="text-sm font-medium text-purple-800 mb-2">Treatment Summary:</div>
                <div class="text-sm text-purple-700">{{ selectedAppointment.completionData.generalNotes.treatmentSummary }}</div>
              </div>
              
              <div v-if="selectedAppointment.completionData.generalNotes.ownerInstructions" class="bg-indigo-50 rounded-lg p-4 border border-indigo-100">
                <div class="text-sm font-medium text-indigo-800 mb-2">Owner Instructions:</div>
                <div class="text-sm text-indigo-700">{{ selectedAppointment.completionData.generalNotes.ownerInstructions }}</div>
              </div>
              
              <div v-if="selectedAppointment.completionData.generalNotes.nextSteps" class="bg-amber-50 rounded-lg p-4 border border-amber-100">
                <div class="text-sm font-medium text-amber-800 mb-2">Next Steps:</div>
                <div class="text-sm text-amber-700">{{ selectedAppointment.completionData.generalNotes.nextSteps }}</div>
              </div>
            </div>
          </div>
          
          <!-- No completion data message -->
          <div v-else class="text-center py-8">
            <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
            </div>
            <h3 class="text-lg font-medium text-gray-900 mb-2">No Completion Notes Available</h3>
            <p class="text-gray-500">This appointment was completed but no detailed notes were added by the veterinarian.</p>
          </div>
          
          <!-- Close button -->
          <div class="flex justify-end mt-6 pt-4 border-t border-gray-200">
            <button 
              @click="closeSummaryModal" 
              class="px-3 sm:px-4 py-1.5 sm:py-2 rounded-full bg-red-200 text-red-800 hover:bg-red-300 transition-colors text-xs sm:text-sm"
            >
              Close
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Prescription Modal -->
    <div 
      v-if="showPrescriptionModal" 
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-2 sm:p-4"
      @click.self="closePrescriptionModal"
    >
      <div class="bg-white rounded-xl shadow-xl max-w-sm sm:max-w-4xl w-full max-h-[95vh] sm:max-h-[90vh] overflow-hidden">
        <div class="p-4 sm:p-6 overflow-y-auto max-h-[calc(95vh-3rem)] sm:max-h-[calc(90vh-3rem)]">
          <div class="flex justify-between items-center mb-4">
            <h2 class="text-lg sm:text-xl font-bold text-gray-900 flex items-center gap-2">
              🏥 Prescription Details
            </h2>
          </div>
          
          <!-- Appointment Details Header -->
          <div class="bg-red-50 rounded-lg p-4 mb-6 border border-red-200">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <h3 class="text-lg font-semibold text-gray-900 mb-2">
                  {{ selectedAppointment?.serviceNames && selectedAppointment.serviceNames.length > 0 
                    ? selectedAppointment.serviceNames.join(', ') 
                    : 'Appointment' }}
                </h3>
                <div class="space-y-1 text-sm text-gray-600">
                  <div><strong>Doctor:</strong> {{ selectedAppointment?.doctorName }}</div>
                  <div><strong>Pet:</strong> {{ getPetDisplayName(selectedAppointment) }}</div>
                  <div><strong>Date:</strong> {{ selectedAppointment ? formatDate(selectedAppointment.date) : '' }}</div>
                  <div><strong>Time:</strong> {{ selectedAppointment?.time }}</div>
                  <div><strong>Status:</strong> <span class="text-green-600 font-medium">Completed</span></div>
                </div>
              </div>
              <div class="flex items-center justify-center">
                <div class="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center">
                  <svg class="w-8 h-8 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                  </svg>
                </div>
              </div>
            </div>
          </div>

          <!-- Prescription Content -->
          <div v-if="selectedAppointment?.completionData?.prescription" class="space-y-6">
            <!-- Medications List -->
            <div v-if="selectedAppointment.completionData.prescription.medications && selectedAppointment.completionData.prescription.medications.length > 0">
              <h4 class="text-lg font-semibold text-gray-900 mb-3 flex items-center gap-2">
                <svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                </svg>
                Prescribed Medications
              </h4>
              <div class="space-y-4">
                <div v-for="(medication, index) in selectedAppointment.completionData.prescription.medications" :key="index" class="bg-red-50 rounded-lg p-4 border border-red-200">
                  <div class="flex items-center justify-between mb-3">
                    <h5 class="text-lg font-semibold text-red-800">Medication {{ index + 1 }}</h5>
                    <span class="text-xs text-red-600 bg-red-100 px-2 py-1 rounded-full">Prescribed</span>
                  </div>
                  
                  <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div v-if="medication.name">
                      <div class="text-sm font-medium text-red-700 mb-1">Medication Name:</div>
                      <div class="text-sm text-red-800 font-semibold">{{ medication.name }}</div>
                    </div>
                    
                    <div v-if="medication.dosage">
                      <div class="text-sm font-medium text-red-700 mb-1">Dosage:</div>
                      <div class="text-sm text-red-800">{{ medication.dosage }}</div>
                    </div>
                    
                    <div v-if="medication.frequency">
                      <div class="text-sm font-medium text-red-700 mb-1">Frequency:</div>
                      <div class="text-sm text-red-800">{{ medication.frequency }}</div>
                    </div>
                    
                    <div v-if="medication.duration">
                      <div class="text-sm font-medium text-red-700 mb-1">Duration:</div>
                      <div class="text-sm text-red-800">{{ medication.duration }}</div>
                    </div>
                    
                    <div v-if="medication.instructions" class="md:col-span-2">
                      <div class="text-sm font-medium text-red-700 mb-1">Special Instructions:</div>
                      <div class="text-sm text-red-800 bg-white rounded p-3 border border-red-200">
                        {{ medication.instructions }}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- General Prescription Instructions -->
            <div v-if="selectedAppointment.completionData.prescription.instructions" class="bg-blue-50 rounded-lg p-4 border border-blue-200">
              <h4 class="text-lg font-semibold text-gray-900 mb-3 flex items-center gap-2">
                <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                General Instructions
              </h4>
              <div class="text-sm text-blue-800 bg-white rounded p-3 border border-blue-200">
                {{ selectedAppointment.completionData.prescription.instructions }}
              </div>
            </div>
            
            <!-- Warnings and Contraindications -->
            <div v-if="selectedAppointment.completionData.prescription.warnings" class="bg-orange-50 rounded-lg p-4 border border-orange-200">
              <h4 class="text-lg font-semibold text-gray-900 mb-3 flex items-center gap-2">
                <svg class="w-5 h-5 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
                </svg>
                ⚠️ Warnings & Contraindications
              </h4>
              <div class="text-sm text-orange-800 bg-white rounded p-3 border border-orange-200">
                {{ selectedAppointment.completionData.prescription.warnings }}
              </div>
            </div>
            
            <!-- Follow-up Information -->
            <div v-if="selectedAppointment.completionData.prescription.followUpRequired" class="bg-green-50 rounded-lg p-4 border border-green-200">
              <h4 class="text-lg font-semibold text-gray-900 mb-3 flex items-center gap-2">
                <svg class="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                </svg>
                Follow-up Required
              </h4>
              <div class="text-sm text-green-800">
                <div class="mb-2">This prescription requires follow-up monitoring.</div>
                <div v-if="selectedAppointment.completionData.prescription.followUpDate" class="font-medium">
                  Follow-up Date: {{ formatDate(new Date(selectedAppointment.completionData.prescription.followUpDate)) }}
                </div>
              </div>
            </div>
          </div>
          
          <!-- No prescription data message -->
          <div v-else class="text-center py-8">
            <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
            </div>
            <h3 class="text-lg font-medium text-gray-900 mb-2">No Prescription Available</h3>
            <p class="text-gray-500">No prescription information was provided for this appointment.</p>
          </div>
          
          <!-- Action buttons -->
          <div class="mt-6 pt-4 border-t border-gray-200 flex flex-row gap-1.5 sm:gap-4">
            <button 
              v-if="selectedAppointment?.completionData?.prescription"
              @click="downloadPrescription(selectedAppointment)" 
              :disabled="isGeneratingPDF"
              :class="[
                'flex-1 px-1.5 sm:px-3 py-1 sm:py-2 rounded-full transition-colors flex items-center justify-center gap-1 sm:gap-2 text-xs sm:text-sm',
                isGeneratingPDF 
                  ? 'bg-gray-400 cursor-not-allowed' 
                  : 'bg-blue-500 text-white hover:bg-blue-700'
              ]"
            >
              <svg v-if="isGeneratingPDF" class="w-2.5 h-2.5 sm:w-4 sm:h-4 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
              </svg>
              <svg v-else class="w-2.5 h-2.5 sm:w-4 sm:h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
              <span class="hidden xs:inline">{{ isGeneratingPDF ? 'Generating PDF...' : 'Download Prescription' }}</span>
              <span class="xs:hidden">{{ isGeneratingPDF ? 'Generating...' : 'Download' }}</span>
            </button>
            <button 
              v-if="selectedAppointment?.completionData?.prescription"
              @click="printPrescription(selectedAppointment)" 
              class="flex-1 px-1.5 sm:px-3 py-1 sm:py-2 rounded-full bg-purple-500 text-white hover:bg-purple-700 transition-colors flex items-center justify-center gap-1 sm:gap-2 text-xs sm:text-sm"
            >
              <svg class="w-2.5 h-2.5 sm:w-4 sm:h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"></path>
              </svg>
              <span class="hidden xs:inline">Print Prescription</span>
              <span class="xs:hidden">Print</span>
            </button>
            <button 
              @click="closePrescriptionModal" 
              class="flex-1 px-1.5 sm:px-3 py-1 sm:py-2 rounded-full bg-red-200 text-red-800 hover:bg-red-300 transition-colors text-xs sm:text-sm"
            >
              Close
            </button>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref, onMounted, onUnmounted, watch, computed } from 'vue';
import { useRouter } from 'vue-router';
  import { 
    X as XIcon, 
    Calendar as CalendarIcon, 
    AlertTriangle as AlertTriangleIcon,
    AlertCircle as AlertCircleIcon
  } from 'lucide-vue-next';
  import { useAppointmentStore } from '@/stores/modules/appointmentStore';
  import { useAuthStore } from '@/stores/modules/authStore';
  import { useProfileStore } from '@/stores/modules/profileStore';
  import { useNotificationsStore } from '@/stores/modules/notifications';
  import { parseISO, format } from 'date-fns';
import { getFirestore, collection, query, where, getDocs } from 'firebase/firestore';
  import AppointmentFeedback from '@/components/user/AppointmentFeedback.vue';
  
  const props = defineProps({
    isMobileView: {
      type: Boolean,
      default: false
    },
    isVisible: {
      type: Boolean,
      default: false
    }
  });
  
  const emit = defineEmits(['close']);
  
  // State
  const loading = ref(false);
  const error = ref(null);
  const appointments = ref([]);
  const showCancelModal = ref(false);
  const showFeedbackModal = ref(false);
  const showSummaryModal = ref(false);
  const showPrescriptionModal = ref(false);
  const selectedAppointment = ref(null);
  const openActionMenu = ref(null); // Track which action menu is open
  const cancelLoading = ref(false);
  const cancellationReason = ref('');
  const reasonError = ref('');
  const isVisibleRef = ref(false);
  const isGeneratingPDF = ref(false);
  
  // Store instances
  const appointmentStore = useAppointmentStore();
  const authStore = useAuthStore();
  const profileStore = useProfileStore();
  const notificationStore = useNotificationsStore();
  const router = useRouter();
  
  // Computed property to determine if the panel is visible
  const panelVisibility = computed(() => props.isVisible);
  
  // Methods
  const closeHistory = () => {
    emit('close');
  };
  
  // Helper function to get effective status (considers both direct status and rescheduleRequest status)
  const getEffectiveStatus = (appointment) => {
    if (!appointment) return null;
    
    // Check if there's a reschedule request that should override the main status
    if (appointment.rescheduleRequest && appointment.rescheduleRequest.status) {
      return appointment.rescheduleRequest.status;
    }
    
    // Return the main status if no reschedule request
    return appointment.status;
  };
  
  // Helper function to get pet display name
  const getPetDisplayName = (appointment) => {
    // Check if we have petNames array (multiple pets)
    if (appointment.petNames && Array.isArray(appointment.petNames) && appointment.petNames.length > 0) {
      return appointment.petNames.join(', ');
    }
    
    // Check if we have petName (single pet)
    if (appointment.petName && appointment.petName.trim()) {
      return appointment.petName.trim();
    }
    
    // Fallback
    return 'No pet info';
  };

  // Helper function to determine if appointment has actionable options
  const hasActionableOptions = (appointment) => {
    if (!appointment) return false;
    
    const status = getEffectiveStatus(appointment)?.toLowerCase();
    
    // Define statuses that have actionable options
    const actionableStatuses = [
      'pending', // Can cancel
      'consider_rescheduling', // Can create new appointment
      'reschedule_requested', // Can create new appointment
      'reschedule_approved', // Can create new appointment
      'reschedule_request_sent', // Can create new appointment
      'completed' // Can view notes, prescription, feedback, schedule follow-up
    ];
    
    return actionableStatuses.includes(status);
  };
  
  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    
    try {
      let date;
      if (typeof dateString === 'string') {
        // Handle ISO string
        date = parseISO(dateString);
      } else if (dateString instanceof Date) {
        // Handle Date object
        date = dateString;
      } else if (dateString && typeof dateString === 'object' && dateString.seconds) {
        // Handle Firebase Timestamp
        date = new Date(dateString.seconds * 1000);
      } else {
        return 'Invalid date';
      }
      
      // Check if date is valid
      if (isNaN(date.getTime())) {
        return 'Invalid date';
      }
      
      const options = { year: 'numeric', month: 'short', day: 'numeric' };
      return date.toLocaleDateString(undefined, options);
    } catch (error) {
      console.error('Error formatting date:', error, dateString);
      return 'Invalid date';
    }
  };
  
  const formatDateTime = (dateString) => {
    if (!dateString) return 'N/A';
    
    try {
      let date;
      if (typeof dateString === 'string') {
        // Handle ISO string
        date = parseISO(dateString);
      } else if (dateString instanceof Date) {
        // Handle Date object
        date = dateString;
      } else if (dateString && typeof dateString === 'object' && dateString.seconds) {
        // Handle Firebase Timestamp
        date = new Date(dateString.seconds * 1000);
      } else {
        return 'Unknown';
      }
      
      // Check if date is valid
      if (isNaN(date.getTime())) {
        return 'Unknown';
      }
      
      return format(date, 'MMM d, yyyy h:mm a');
    } catch (error) {
      console.error('Error formatting date time:', error, dateString);
      return 'Unknown';
    }
  };
  
  const formatStatus = (status) => {
    if (!status) return 'Unknown';
    
    // Handle specific status cases for better readability
    switch (status.toLowerCase()) {
      case 'consider_rescheduling':
        return 'Consider Rescheduling';
      case 'partially_completed':
        return 'Partially Completed';
      case 'reschedule_requested':
        return 'Reschedule Requested';
      case 'reschedule_approved':
        return 'Reschedule Approved';
      case 'reschedule_rejected':
        return 'Reschedule Rejected';
      case 'reschedule_request_sent':
        return 'Reschedule Request Sent';
      default:
        // Capitalize first letter and replace underscores with spaces
        return status.charAt(0).toUpperCase() + status.slice(1).toLowerCase().replace(/_/g, ' ');
    }
  };
  
  // UPDATED: Status class function to use consistent colors with processing status
  const getStatusClass = (appointment) => {
    const baseClasses = 'px-2 py-1 rounded-full text-xs font-medium';
    if (isExpired(appointment)) {
      return `${baseClasses} bg-orange-100 text-orange-800`;
    }
    const status = getEffectiveStatus(appointment)?.toLowerCase();
    switch (status) {
      case 'pending':
        return `${baseClasses} bg-yellow-100 text-yellow-800`;
      case 'approved':
        return `${baseClasses} bg-green-100 text-green-800`;
      case 'completed':
        return `${baseClasses} bg-blue-100 text-blue-800`;
      case 'processing':
        return `${baseClasses} bg-indigo-100 text-indigo-800`;
      case 'consider_rescheduling':
        return `${baseClasses} bg-orange-100 text-orange-800`;
      case 'reschedule_requested':
        return `${baseClasses} bg-orange-100 text-orange-800`;
      case 'reschedule_approved':
        return `${baseClasses} bg-blue-100 text-blue-800`;
      case 'reschedule_rejected':
        return `${baseClasses} bg-red-100 text-red-800`;
      case 'reschedule_request_sent':
        return `${baseClasses} bg-orange-100 text-orange-800`;
      case 'cancelled':
      case 'rejected':
        return `${baseClasses} bg-red-100 text-red-800`;
      case 'ended':
        return `${baseClasses} bg-slate-200 text-slate-700`;
      default:
        return `${baseClasses} bg-gray-100 text-gray-800`;
    }
  };

  // Determine if appointment is expired (past scheduled time) and not final statuses
  const isExpired = (appointment) => {
    if (!appointment) return false;
    
    try {
      const status = (getEffectiveStatus(appointment) || '').toLowerCase();
      if (['approved','completed','cancelled','rejected','ended','consider_rescheduling','reschedule_requested','reschedule_approved','reschedule_rejected','reschedule_request_sent'].includes(status)) return false;
      if (!appointment.date || !appointment.time) return false;
      
      let appointmentDate;
      if (appointment.date instanceof Date) {
        appointmentDate = appointment.date;
      } else if (typeof appointment.date === 'string') {
        appointmentDate = new Date(appointment.date);
      } else if (appointment.date && typeof appointment.date === 'object' && appointment.date.seconds) {
        // Handle Firebase Timestamp
        appointmentDate = new Date(appointment.date.seconds * 1000);
      } else {
        return false;
      }
      
      // Check if date is valid
      if (isNaN(appointmentDate.getTime())) {
        return false;
      }
      
      const timeStr = String(appointment.time);
      // Parse end time from range "h:mm AM - h:mm PM"; fallback to first time if missing range
      const matches = timeStr.match(/(\d{1,2}):(\d{2})\s*(AM|PM)(?:\s*-\s*(\d{1,2}):(\d{1,2})\s*(AM|PM))?/i);
      if (!matches) return false;
      
      let endHour, endMinute, endPeriod;
      if (matches[4]) {
        endHour = parseInt(matches[4]);
        endMinute = parseInt(matches[5]);
        endPeriod = matches[6].toUpperCase();
      } else {
        endHour = parseInt(matches[1]);
        endMinute = parseInt(matches[2]);
        endPeriod = matches[3].toUpperCase();
      }
      
      if (endPeriod === 'PM' && endHour !== 12) endHour += 12;
      if (endPeriod === 'AM' && endHour === 12) endHour = 0;
      
      const endDateTime = new Date(appointmentDate);
      endDateTime.setHours(endHour, endMinute, 0, 0);
      
      return new Date() > endDateTime;
    } catch (error) {
      console.error('Error checking if appointment is expired:', error, appointment);
      return false;
    }
  };
  
  const fetchUserAppointments = async (forceRefresh = false) => {
    if (!authStore.user || !authStore.user.userId) {
      error.value = 'You must be logged in to view appointments';
      return;
    }
    
    // Check if we have cached data and don't need to refresh
    const hasCachedData = appointmentStore.isDataCached(authStore.user.userId);
    if (hasCachedData && !forceRefresh && appointments.value.length > 0) {
      console.log('Using cached appointment data - no loading needed');
      return;
    }
    
    // Only show loading if we don't have any data yet
    if (appointments.value.length === 0) {
    loading.value = true;
    }
    error.value = null;
    
    try {
      // Use the appointmentStore to fetch data with caching
      const userAppointments = await appointmentStore.fetchAppointmentsByUserId(authStore.user.userId, forceRefresh);
      
      // Show all appointments in history (not just completed ones)
      appointments.value = userAppointments;
      
      // Sort appointments by date (newest first)
      appointments.value.sort((a, b) => {
        const dateA = new Date(a.date);
        const dateB = new Date(b.date);
        return dateB - dateA;
      });
      
      // Check for existing feedback for completed appointments
      await checkExistingFeedback();
    } catch (err) {
      console.error('Error fetching appointments:', err);
      error.value = 'Failed to load your appointments. Please try again.';
    } finally {
      loading.value = false;
    }
  };

  // Manual refresh function for external use
  const refreshAppointments = async (forceRefresh = true) => {
    console.log('Manually refreshing appointment data');
    await fetchUserAppointments(forceRefresh);
  };

  // Expose refresh function for parent components
  defineExpose({
    refreshAppointments
  });
  
  // Check for existing feedback for completed appointments
  const checkExistingFeedback = async () => {
    try {
      const { getFeedbackByAppointmentId } = await import('@/services/feedbackService');
      
      // Check only completed appointments
      const completedAppointments = appointments.value.filter(app => app.status === 'completed');
      
      if (completedAppointments.length === 0) {
        return; // No completed appointments to check
      }
      
      for (const appointment of completedAppointments) {
        try {
          if (!appointment.id) {
            console.warn('Appointment missing ID, skipping feedback check');
            continue;
          }
          
          const existingFeedback = await getFeedbackByAppointmentId(appointment.id);
          if (existingFeedback) {
            appointment.hasFeedback = true;
            appointment.existingFeedback = existingFeedback;
          } else {
            appointment.hasFeedback = false;
            appointment.existingFeedback = null;
          }
        } catch (error) {
          console.error(`Error checking feedback for appointment ${appointment.id}:`, error);
          appointment.hasFeedback = false;
          appointment.existingFeedback = null;
        }
      }
    } catch (error) {
      console.error('Error importing feedback service:', error);
      // Don't set error state here as it's not critical for the main functionality
    }
  };
  
  // Simplified canCancel function - we're now checking directly in the template
  // This function is kept for potential future use
  const canCancel = (appointment) => {
    return appointment && appointment.status?.toLowerCase() === 'pending';
  };
  
  const confirmCancel = (appointment) => {
    selectedAppointment.value = appointment;
    cancellationReason.value = ''; // Reset reason
    reasonError.value = ''; // Reset error
    showCancelModal.value = true;
    document.body.classList.add('modal-open'); // Prevent body scrolling
    closeActionMenu(); // Close menu after action
  };
  
  const closeCancelModal = () => {
    showCancelModal.value = false;
    selectedAppointment.value = null;
    cancellationReason.value = '';
    reasonError.value = '';
    document.body.classList.remove('modal-open'); // Restore body scrolling
  };
  
  const cancelAppointment = async () => {
    if (!selectedAppointment.value) return;
    
    // Validate reason
    if (!cancellationReason.value.trim()) {
      reasonError.value = 'Please provide a reason for cancellation';
      return;
    }
    
    cancelLoading.value = true;
    
    try {
      // Update the appointment status to cancelled with reason
      await appointmentStore.updateAppointment(
        selectedAppointment.value.id, 
        {
          status: 'cancelled',
          cancellationReason: cancellationReason.value.trim(),
          cancelledBy: 'user',
          cancelledAt: new Date()
        }
      );
      
      // Update the local state
      const index = appointments.value.findIndex(a => a.id === selectedAppointment.value.id);
      if (index !== -1) {
        appointments.value[index].status = 'cancelled';
        appointments.value[index].cancellationReason = cancellationReason.value.trim();
        appointments.value[index].cancelledBy = 'user';
        appointments.value[index].cancelledAt = new Date();
      }
      
      // Close the modal
      closeCancelModal();
    } catch (err) {
      console.error('Error cancelling appointment:', err);
      error.value = 'Failed to cancel appointment. Please try again.';
    } finally {
      cancelLoading.value = false;
    }
  };

  // Feedback methods
  const openFeedback = async (appointment) => {
    // Ensure appointment has all required data for feedback
    if (!appointment.petName) {
      console.warn('Appointment missing petName, attempting to fetch pet data...');
      
      try {
        // Try to get pet information from the pets collection
        const db = getFirestore();
        const petsRef = collection(db, 'pets');
        
        // First try to find pet by petId if it exists in the appointment
        let petQuery;
        if (appointment.petId) {
          petQuery = query(petsRef, where('__name__', '==', appointment.petId));
        } else {
          // Fallback to finding by ownerId
          petQuery = query(petsRef, where('ownerId', '==', appointment.userId));
        }
        
        const petSnapshot = await getDocs(petQuery);
        
        if (!petSnapshot.empty) {
          // Find the pet that matches the appointment
          let petDoc;
          if (appointment.petId) {
            petDoc = petSnapshot.docs[0]; // Should be only one if searching by petId
          } else {
            // Find the first pet for this owner (you might need to adjust this logic)
            petDoc = petSnapshot.docs[0];
          }
          
          if (petDoc) {
            const petData = petDoc.data();
            appointment.petName = petData.name || petData.petName || 'Unknown Pet';
          } else {
            appointment.petName = 'Unknown Pet';
          }
        } else {
          appointment.petName = 'Unknown Pet';
        }
      } catch (error) {
        console.error('Error fetching pet data:', error);
        appointment.petName = 'Unknown Pet';
      }
    }
    
    // Check if feedback already exists for this appointment
    try {
      const { getFeedbackByAppointmentId } = await import('@/services/feedbackService');
      const existingFeedback = await getFeedbackByAppointmentId(appointment.id);
      
      if (existingFeedback) {
        // Mark appointment as having feedback
        appointment.hasFeedback = true;
        appointment.existingFeedback = existingFeedback;
      } else {
        appointment.hasFeedback = false;
        appointment.existingFeedback = null;
      }
    } catch (error) {
      console.error('Error checking for existing feedback:', error);
      appointment.hasFeedback = false;
      appointment.existingFeedback = null;
    }
    
    selectedAppointment.value = appointment;
    showFeedbackModal.value = true;
    document.body.classList.add('modal-open'); // Prevent body scrolling
    closeActionMenu(); // Close menu after action
  };

  const closeFeedbackModal = () => {
    showFeedbackModal.value = false;
    selectedAppointment.value = null;
    document.body.classList.remove('modal-open'); // Restore body scrolling
  };

  const onFeedbackSubmitted = async (feedbackData) => {
    console.log('Feedback submitted:', feedbackData);
    
    // Update the appointment's feedback status
    if (selectedAppointment.value) {
      selectedAppointment.value.hasFeedback = true;
      selectedAppointment.value.existingFeedback = feedbackData;
    }
    
    // Refresh the feedback status for all appointments
    await checkExistingFeedback();
  };

  // Action menu methods
  const toggleActionMenu = (appointmentId) => {
    if (openActionMenu.value === appointmentId) {
      openActionMenu.value = null; // Close if already open
    } else {
      openActionMenu.value = appointmentId; // Open this menu
    }
  };

  const closeActionMenu = () => {
    openActionMenu.value = null;
  };

  // Summary modal methods
  const viewAppointmentSummary = (appointment) => {
    selectedAppointment.value = appointment;
    showSummaryModal.value = true;
    document.body.classList.add('modal-open'); // Prevent body scrolling
    closeActionMenu(); // Close menu after action
  };

  const closeSummaryModal = () => {
    showSummaryModal.value = false;
    selectedAppointment.value = null;
    document.body.classList.remove('modal-open'); // Restore body scrolling
  };

  // Prescription modal methods
  const viewPrescription = (appointment) => {
    selectedAppointment.value = appointment;
    showPrescriptionModal.value = true;
    document.body.classList.add('modal-open'); // Prevent body scrolling
    closeActionMenu(); // Close menu after action
  };

  const closePrescriptionModal = () => {
    showPrescriptionModal.value = false;
    selectedAppointment.value = null;
    document.body.classList.remove('modal-open'); // Restore body scrolling
  };

  // Download prescription as PDF
  const downloadPrescription = async (appointment) => {
    if (!appointment?.completionData?.prescription) {
      console.error('No prescription data available for download');
      return;
    }

    try {
      isGeneratingPDF.value = true;
      
      // Import required libraries
      const { default: jsPDF } = await import('jspdf');
      const html2canvas = (await import('html2canvas')).default;
      
      // Create prescription content
      const prescriptionData = appointment.completionData.prescription;
      
      // Get client/owner information from auth store
      const clientName = authStore.user ? `${authStore.user.firstName || ''} ${authStore.user.lastName || ''}`.trim() : 'Unknown Client';
      const clientId = authStore.user?.userId || 'Unknown ID';
      
      // Get pet information using the same logic as getPetDisplayName
      let petName = getPetDisplayName(appointment);
      let petId = 'Unknown ID';
      let petAge = '';
      
      // Get pet ID
      if (appointment.petId) {
        petId = appointment.petId;
      } else if (appointment.petIds && Array.isArray(appointment.petIds) && appointment.petIds.length > 0) {
        petId = appointment.petIds[0];
      }
      
      // Try to get pet age from appointment data first
      if (appointment.petAgeYears !== undefined || appointment.petAgeMonths !== undefined || appointment.petAgeWeeks !== undefined) {
        const ageParts = [];
        if (appointment.petAgeYears > 0) ageParts.push(`${appointment.petAgeYears} year${appointment.petAgeYears > 1 ? 's' : ''}`);
        if (appointment.petAgeMonths > 0) ageParts.push(`${appointment.petAgeMonths} month${appointment.petAgeMonths > 1 ? 's' : ''}`);
        if (appointment.petAgeWeeks > 0) ageParts.push(`${appointment.petAgeWeeks} week${appointment.petAgeWeeks > 1 ? 's' : ''}`);
        petAge = ageParts.join(', ');
      } else if (appointment.petAges && Array.isArray(appointment.petAges) && appointment.petAges.length > 0) {
        // Handle multiple pets - use first pet's age
        const firstPetAge = appointment.petAges[0];
        if (firstPetAge) {
          const ageParts = [];
          if (firstPetAge.years > 0) ageParts.push(`${firstPetAge.years} year${firstPetAge.years > 1 ? 's' : ''}`);
          if (firstPetAge.months > 0) ageParts.push(`${firstPetAge.months} month${firstPetAge.months > 1 ? 's' : ''}`);
          if (firstPetAge.weeks > 0) ageParts.push(`${firstPetAge.weeks} week${firstPetAge.weeks > 1 ? 's' : ''}`);
          petAge = ageParts.join(', ');
        }
      }
      
      // Try to get pet age from completion data as fallback
      if (!petAge && appointment.completionData?.pets && appointment.completionData.pets.length > 0) {
        const petData = appointment.completionData.pets[0];
        if (petData.ageYears !== undefined || petData.ageMonths !== undefined || petData.ageWeeks !== undefined) {
          const ageParts = [];
          if (petData.ageYears > 0) ageParts.push(`${petData.ageYears} year${petData.ageYears > 1 ? 's' : ''}`);
          if (petData.ageMonths > 0) ageParts.push(`${petData.ageMonths} month${petData.ageMonths > 1 ? 's' : ''}`);
          if (petData.ageWeeks > 0) ageParts.push(`${petData.ageWeeks} week${petData.ageWeeks > 1 ? 's' : ''}`);
          petAge = ageParts.join(', ');
        }
      }
      
      // Try to fetch pet age from pets store as final fallback
      if (!petAge && petId && petId !== 'Unknown ID') {
        try {
          // Import pets store to get pet data
          const { usePetsStore } = await import('@/stores/modules/petsStore');
          const petsStore = usePetsStore();
          
          // Fetch user pets to get the specific pet data
          if (authStore.user?.userId) {
            await petsStore.fetchUserPets(authStore.user.userId);
            const userPets = petsStore.getPets;
            const pet = userPets.find(p => p.id === petId);
            
            if (pet) {
              const ageParts = [];
              if (pet.ageYears > 0) ageParts.push(`${pet.ageYears} year${pet.ageYears > 1 ? 's' : ''}`);
              if (pet.ageMonths > 0) ageParts.push(`${pet.ageMonths} month${pet.ageMonths > 1 ? 's' : ''}`);
              if (pet.ageWeeks > 0) ageParts.push(`${pet.ageWeeks} week${pet.ageWeeks > 1 ? 's' : ''}`);
              petAge = ageParts.join(', ');
            }
          }
        } catch (error) {
          console.error('Error fetching pet age from pets store:', error);
        }
      }
      
      // Get client address from profile store
      let clientAddress = '';
      if (authStore.user?.userId) {
        try {
          await profileStore.fetchUserProfile(authStore.user.userId);
          const profile = profileStore.getProfile;
          if (profile) {
            const addressParts = [
              profile.streetAddress,
              profile.city,
              profile.province,
              profile.postalCode,
              profile.country
            ].filter(part => part && part.trim());
            clientAddress = addressParts.join(', ');
          }
        } catch (error) {
          console.error('Error fetching client address:', error);
        }
      }
      
      const appointmentInfo = {
        clientName: clientName,
        clientId: clientId,
        clientAddress: clientAddress,
        petName: petName,
        petId: petId,
        petAge: petAge,
        doctorName: appointment.doctorName || 'Unknown Doctor',
        date: formatDate(appointment.date),
        time: appointment.time,
        serviceNames: appointment.serviceNames?.join(', ') || 'Appointment'
      };

      // Create a temporary container for the prescription HTML
      const tempContainer = document.createElement('div');
      tempContainer.style.position = 'absolute';
      tempContainer.style.left = '-9999px';
      tempContainer.style.top = '-9999px';
      tempContainer.style.width = '8.3in';
      tempContainer.style.backgroundColor = 'white';
      tempContainer.innerHTML = generatePrescriptionPDF(prescriptionData, appointmentInfo);
      document.body.appendChild(tempContainer);

      // Wait for fonts and images to load
      await new Promise(resolve => setTimeout(resolve, 1000));

      // Convert HTML to canvas
      const canvas = await html2canvas(tempContainer, {
        scale: 2,
        useCORS: true,
        allowTaint: true,
        backgroundColor: '#ffffff',
        width: tempContainer.offsetWidth,
        height: tempContainer.offsetHeight
      });

      // Remove temporary container
      document.body.removeChild(tempContainer);

      // Create PDF
      const pdf = new jsPDF({
        orientation: 'portrait',
        unit: 'in',
        format: 'letter'
      });

      // Calculate dimensions for maximum form size on coupon bond (8.5" x 11")
      const imgWidth = 8.3; // Use 8.3" width for maximum form size
      const pageHeight = 11;
      const imgHeight = (canvas.height * imgWidth) / canvas.width;
      let heightLeft = imgHeight;

      // Add image to PDF
      const imgData = canvas.toDataURL('image/png');
      let position = 0;

      pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
      heightLeft -= pageHeight;

      // Add new pages if needed
      while (heightLeft >= 0) {
        position = heightLeft - imgHeight;
        pdf.addPage();
        pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
        heightLeft -= pageHeight;
      }

      // Save the PDF
      const fileName = `Prescription_${appointmentInfo.petName}_${appointmentInfo.date.replace(/\//g, '-')}.pdf`;
      pdf.save(fileName);
      
      console.log('Prescription PDF downloaded successfully');
    } catch (error) {
      console.error('Error downloading prescription PDF:', error);
    } finally {
      isGeneratingPDF.value = false;
    }
  };

  // Print prescription directly
  const printPrescription = async (appointment) => {
    if (!appointment?.completionData?.prescription) {
      console.error('No prescription data available for printing');
      return;
    }

    try {
      // Import required libraries
      const { default: jsPDF } = await import('jspdf');
      const html2canvas = (await import('html2canvas')).default;
      
      // Create prescription content
      const prescriptionData = appointment.completionData.prescription;
      
      // Get client/owner information from auth store
      const clientName = authStore.user ? `${authStore.user.firstName || ''} ${authStore.user.lastName || ''}`.trim() : 'Unknown Client';
      const clientId = authStore.user?.userId || 'Unknown ID';
      
      // Get pet information using the same logic as getPetDisplayName
      let petName = getPetDisplayName(appointment);
      let petId = 'Unknown ID';
      let petAge = '';
      
      // Get pet ID
      if (appointment.petId) {
        petId = appointment.petId;
      } else if (appointment.petIds && Array.isArray(appointment.petIds) && appointment.petIds.length > 0) {
        petId = appointment.petIds[0];
      }
      
      // Try to get pet age from appointment data first
      if (appointment.petAgeYears !== undefined || appointment.petAgeMonths !== undefined || appointment.petAgeWeeks !== undefined) {
        const ageParts = [];
        if (appointment.petAgeYears > 0) ageParts.push(`${appointment.petAgeYears} year${appointment.petAgeYears > 1 ? 's' : ''}`);
        if (appointment.petAgeMonths > 0) ageParts.push(`${appointment.petAgeMonths} month${appointment.petAgeMonths > 1 ? 's' : ''}`);
        if (appointment.petAgeWeeks > 0) ageParts.push(`${appointment.petAgeWeeks} week${appointment.petAgeWeeks > 1 ? 's' : ''}`);
        petAge = ageParts.join(', ');
      } else if (appointment.petAges && Array.isArray(appointment.petAges) && appointment.petAges.length > 0) {
        // Handle multiple pets - use first pet's age
        const firstPetAge = appointment.petAges[0];
        if (firstPetAge) {
          const ageParts = [];
          if (firstPetAge.years > 0) ageParts.push(`${firstPetAge.years} year${firstPetAge.years > 1 ? 's' : ''}`);
          if (firstPetAge.months > 0) ageParts.push(`${firstPetAge.months} month${firstPetAge.months > 1 ? 's' : ''}`);
          if (firstPetAge.weeks > 0) ageParts.push(`${firstPetAge.weeks} week${firstPetAge.weeks > 1 ? 's' : ''}`);
          petAge = ageParts.join(', ');
        }
      }
      
      // Try to get pet age from completion data as fallback
      if (!petAge && appointment.completionData?.pets && appointment.completionData.pets.length > 0) {
        const petData = appointment.completionData.pets[0];
        if (petData.ageYears !== undefined || petData.ageMonths !== undefined || petData.ageWeeks !== undefined) {
          const ageParts = [];
          if (petData.ageYears > 0) ageParts.push(`${petData.ageYears} year${petData.ageYears > 1 ? 's' : ''}`);
          if (petData.ageMonths > 0) ageParts.push(`${petData.ageMonths} month${petData.ageMonths > 1 ? 's' : ''}`);
          if (petData.ageWeeks > 0) ageParts.push(`${petData.ageWeeks} week${petData.ageWeeks > 1 ? 's' : ''}`);
          petAge = ageParts.join(', ');
        }
      }
      
      // Try to fetch pet age from pets store as final fallback
      if (!petAge && petId && petId !== 'Unknown ID') {
        try {
          // Import pets store to get pet data
          const { usePetsStore } = await import('@/stores/modules/petsStore');
          const petsStore = usePetsStore();
          
          // Fetch user pets to get the specific pet data
          if (authStore.user?.userId) {
            await petsStore.fetchUserPets(authStore.user.userId);
            const userPets = petsStore.getPets;
            const pet = userPets.find(p => p.id === petId);
            
            if (pet) {
              const ageParts = [];
              if (pet.ageYears > 0) ageParts.push(`${pet.ageYears} year${pet.ageYears > 1 ? 's' : ''}`);
              if (pet.ageMonths > 0) ageParts.push(`${pet.ageMonths} month${pet.ageMonths > 1 ? 's' : ''}`);
              if (pet.ageWeeks > 0) ageParts.push(`${pet.ageWeeks} week${pet.ageWeeks > 1 ? 's' : ''}`);
              petAge = ageParts.join(', ');
            }
          }
        } catch (error) {
          console.error('Error fetching pet age from pets store:', error);
        }
      }
      
      // Get client address from profile store
      let clientAddress = '';
      if (authStore.user?.userId) {
        try {
          await profileStore.fetchUserProfile(authStore.user.userId);
          const profile = profileStore.getProfile;
          if (profile) {
            const addressParts = [
              profile.streetAddress,
              profile.city,
              profile.province,
              profile.postalCode,
              profile.country
            ].filter(part => part && part.trim());
            clientAddress = addressParts.join(', ');
          }
        } catch (error) {
          console.error('Error fetching client address:', error);
        }
      }
      
      const appointmentInfo = {
        clientName: clientName,
        clientId: clientId,
        clientAddress: clientAddress,
        petName: petName,
        petId: petId,
        petAge: petAge,
        doctorName: appointment.doctorName || 'Unknown Doctor',
        date: formatDate(appointment.date),
        time: appointment.time,
        serviceNames: appointment.serviceNames?.join(', ') || 'Appointment'
      };

      // Create a temporary container for the prescription HTML
      const tempContainer = document.createElement('div');
      tempContainer.style.position = 'absolute';
      tempContainer.style.left = '-9999px';
      tempContainer.style.top = '-9999px';
      tempContainer.style.width = '8.3in';
      tempContainer.style.backgroundColor = 'white';
      tempContainer.innerHTML = generatePrescriptionPDF(prescriptionData, appointmentInfo);
      document.body.appendChild(tempContainer);

      // Wait for fonts and images to load
      await new Promise(resolve => setTimeout(resolve, 1000));

      // Convert HTML to canvas
      const canvas = await html2canvas(tempContainer, {
        scale: 2,
        useCORS: true,
        allowTaint: true,
        backgroundColor: '#ffffff',
        width: tempContainer.offsetWidth,
        height: tempContainer.offsetHeight
      });

      // Remove temporary container
      document.body.removeChild(tempContainer);

      // Create PDF
      const pdf = new jsPDF({
        orientation: 'portrait',
        unit: 'in',
        format: 'letter'
      });

      // Calculate dimensions for maximum form size on coupon bond (8.5" x 11")
      const imgWidth = 8.3; // Use 8.3" width for maximum form size
      const pageHeight = 11;
      const imgHeight = (canvas.height * imgWidth) / canvas.width;
      let heightLeft = imgHeight;

      // Add image to PDF
      const imgData = canvas.toDataURL('image/png');
      let position = 0;

      pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
      heightLeft -= pageHeight;

      // Add new pages if needed
      while (heightLeft >= 0) {
        position = heightLeft - imgHeight;
        pdf.addPage();
        pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
        heightLeft -= pageHeight;
      }

      // Open PDF in new window for printing
      const pdfBlob = pdf.output('blob');
      const pdfUrl = URL.createObjectURL(pdfBlob);
      const printWindow = window.open(pdfUrl, '_blank');
      
      // Wait for PDF to load then trigger print
      printWindow.onload = () => {
        printWindow.print();
        // Close the print window after printing
        printWindow.onafterprint = () => {
          printWindow.close();
          URL.revokeObjectURL(pdfUrl);
        };
      };
      
      console.log('Prescription print dialog opened');
      closeActionMenu(); // Close menu after action
    } catch (error) {
      console.error('Error printing prescription:', error);
    }
  };

  // Generate prescription PDF content
  const generatePrescriptionPDF = (prescriptionData, appointmentInfo) => {
    const medications = prescriptionData.medications || [];
    const instructions = prescriptionData.instructions || '';
    const warnings = prescriptionData.warnings || '';
    const followUpRequired = prescriptionData.followUpRequired || false;
    const followUpDate = prescriptionData.followUpDate || '';

    return `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Prescription - ${appointmentInfo.petName}</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 0; 
            padding: 0; 
            line-height: 1.3; 
            background-color: white;
            color: #374151;
        }
        .prescription-form {
            width: 100%;
            height: 5.0in; /* Slightly smaller equal height for both cards (5.0in each) */
            margin: 0;
            background: transparent;
            padding: 14px;
            box-shadow: none;
            position: relative;
        }
        
        .prescription-container {
            width: 8.1in; /* Adjusted width for equal margins */
            margin: 0 auto;
            display: flex;
            flex-direction: column;
            gap: 0;
            padding: 0.2in; /* Equal margins on all sides */
            background: white;
            box-shadow: none; /* Remove shadow for cleaner look */
        }
        
        .prescription-copy {
            width: 100%;
            position: relative;
            margin: 0;
        }
        
        .separator-line {
            width: 100%;
            height: 1px;
            border-top: 1px dashed #000;
            margin: 15px 0; /* Better spacing for broken line */
            display: block;
            background: none;
            opacity: 1;
            visibility: visible;
            position: relative;
            z-index: 10;
        }
        .paw-print {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 180px;
            height: 180px;
            opacity: 0.08;
            pointer-events: none;
        }
        .paw-print svg {
            width: 100%;
            height: 100%;
            fill: #666;
        }
        .header {
            text-align: center;
            margin-bottom: 5px;
            border-bottom: 2px solid #374151;
            padding-bottom: 2px;
        }
        .office-name {
            font-size: 20px;
            font-weight: bold;
            color: #374151;
            margin-bottom: 0px;
        }
        .office-address {
            font-size: 16px;
            color: #6b7280;
            margin-bottom: 0px;
        }
        .office-email {
            font-size: 16px;
            color: #6b7280;
            margin-bottom: 0px;
        }
        .office-phone {
            font-size: 16px;
            color: #6b7280;
            text-align: left;
            margin-top: -16px;
        }
        .client-section {
            margin-bottom: 5px;
        }
        .client-row {
            display: flex;
            margin-bottom: 2px;
            align-items: center;
        }
        .client-label {
            font-weight: bold;
            color: #374151;
            min-width: 110px;
            margin-right: 5px;
            font-size: 16px;
        }
        .client-input {
            flex: 1;
            border: none;
            border-bottom: 1px solid #374151;
            padding: 7px 0;
            min-height: 32px;
            background: transparent;
            font-size: 16px;
        }
        .client-row-inline {
            display: flex;
            gap: 20px;
            margin-bottom: 10px;
        }
        .client-inline {
            display: flex;
            align-items: center;
            flex: 1;
        }
        .client-inline .client-label {
            min-width: auto;
            margin-right: 5px;
        }
        .rx-section {
            position: relative;
            margin: 5px 0;
            min-height: 80px;
        }
        .rx-symbol {
            font-size: 36px;
            font-weight: bold;
            color: #374151;
            position: absolute;
            left: 0;
            top: 0;
        }
        .prescription-content {
            margin-left: 50px;
            padding-top: 6px;
        }
        .medication-item {
            margin-bottom: 6px;
            padding: 4px 0;
        }
        .medication-name {
            font-weight: bold;
            font-size: 18px;
            color: #374151;
            margin-bottom: 0px;
        }
        .medication-details {
            font-size: 16px;
            color: #6b7280;
            margin-bottom: 0px;
        }
        .instructions-text {
            font-size: 16px;
            color: #374151;
            margin-bottom: 0px;
        }
        .footer-section {
            margin-top: 5px;
            border-top: none;
            padding-top: 0px;
        }
        .footer-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            margin-bottom: 8px;
        }
        .refill-section {
            display: flex;
            flex-direction: column;
            gap: 0px;
            font-size: 16px;
            color: #374151;
        }
        .refill-section span {
            display: inline;
        }
        .refill-line {
            border: none;
            min-width: 180px;
            padding: 5px 0;
            text-align: right;
            font-size: 16px;
        }
        .refill-options {
            display: flex;
            gap: 16px;
            align-items: center;
            margin-left: 5px;
        }
        .refill-option {
            font-size: 20px;
            color: #374151;
        }
        .doctor-signature {
            border: none;
            border-bottom: 1px solid #374151;
            min-width: 180px;
            padding: 5px 0;
            text-align: right;
            font-size: 16px;
        }
        .disclaimer {
            text-align: center;
            font-weight: bold;
            font-size: 18px;
            color: #374151;
            text-transform: uppercase;
            margin-top: 5px;
            border-top: 2px solid #374151;
            padding-top: 5px;
            font-style: italic;
        }
        @media print { 
            body { 
                margin: 0; 
                padding: 0; 
                background: white !important;
            }
            .prescription-form { 
                box-shadow: none !important;
                height: 5.0in !important; /* Slightly smaller equal height for both cards */
            }
            .prescription-container { 
                width: 8.1in !important;
                display: flex !important;
                flex-direction: column !important;
                padding: 0.2in !important; /* Equal margins on all sides */
                margin: 0 auto !important;
            }
            .prescription-copy { 
                width: 100% !important;
                page-break-inside: avoid;
                height: 5.0in !important; /* Slightly smaller equal height for both cards */
            }
            .separator-line { 
                display: block !important;
                width: 100% !important;
                margin: 15px 0 !important;
                height: 1px !important;
                border-top: 1px dashed #000 !important;
                background: none !important;
                opacity: 1 !important;
                visibility: visible !important;
                position: relative !important;
                z-index: 10 !important;
            }
        }
    </style>
</head>
<body>
    <div class="prescription-container">
        <!-- First Copy -->
        <div class="prescription-copy">
            <div class="prescription-form">
                <div class="paw-print">
                    <svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
                        <path fill="currentColor" d="M234.5 92.9c14.3 42.9-.3 86.2-32.6 96.8s-70.1-15.6-84.4-58.5s.3-86.2 32.6-96.8s70.1 15.6 84.4 58.5M100.4 198.6c18.9 32.4 14.3 70.1-10.2 84.1s-59.7-.9-78.5-33.3s-14.3-70.1 10.2-84.1s59.7.9 78.5 33.3M69.2 401.2C121.6 259.9 214.7 224 256 224s134.4 35.9 186.8 177.2c3.6 9.7 5.2 20.1 5.2 30.5v1.6c0 25.8-20.9 46.7-46.7 46.7c-11.5 0-22.9-1.4-34-4.2l-88-22c-15.3-3.8-31.3-3.8-46.6 0l-88 22c-11.1 2.8-22.5 4.2-34 4.2c-25.8 0-46.7-20.9-46.7-46.7v-1.6c0-10.4 1.6-20.8 5.2-30.5m352.6-118.5c-24.5-14-29.1-51.7-10.2-84.1s54-47.3 78.5-33.3s29.1 51.7 10.2 84.1s-54 47.3-78.5 33.3m-111.7-93c-32.3-10.6-46.9-53.9-32.6-96.8s52.1-69.1 84.4-58.5s46.9 53.9 32.6 96.8s-52.1 69.1-84.4 58.5"/>
                    </svg>
                </div>
        
    <div class="header">
            <div class="office-name">Provincial Veterinary Office of Oriental Mindoro</div>
            <div class="office-address">Capitol Complex, Calapan City, Or.Mindoro</div>
            <div class="office-email">provet_ormdo@yahoo.com</div>
            <div class="office-phone">Phone: (043) 288 7743</div>
    </div>

        <div class="client-section">
            <div class="client-row">
                <span class="client-label">Client Name:</span>
                <div class="client-input">${appointmentInfo.clientName || ''}</div>
            </div>
            <div class="client-row">
                <span class="client-label">Address:</span>
                <div class="client-input">${appointmentInfo.clientAddress || ''}</div>
            </div>
            <div class="client-row">
                <span class="client-label">Patient/Pet Name:</span>
                <div class="client-input">${appointmentInfo.petName || ''}</div>
            </div>
            <div class="client-row-inline">
                <div class="client-inline">
                    <span class="client-label">Age:</span>
                    <div class="client-input">${appointmentInfo.petAge || ''}</div>
                </div>
                <div class="client-inline">
                    <span class="client-label">Date:</span>
                    <div class="client-input">${appointmentInfo.date || ''}</div>
                </div>
            </div>
    </div>

        <div class="rx-section">
            <div class="rx-symbol">℞</div>
            <div class="prescription-content">
                ${medications.length > 0 ? medications.map((med, index) => `
                    <div class="medication-item">
                        <div class="medication-name">${med.name || 'Medication Name'}</div>
            <div class="medication-details">
                            ${med.dosage ? `Dosage: ${med.dosage}` : ''}
                            ${med.frequency ? ` • Frequency: ${med.frequency}` : ''}
                            ${med.duration ? ` • Duration: ${med.duration}` : ''}
            </div>
                        ${med.instructions ? `<div class="instructions-text">Instructions: ${med.instructions}</div>` : ''}
        </div>
                `).join('') : `
                    <div class="medication-item">
                        <div class="medication-name">Medication Name</div>
                        <div class="medication-details"></div>
                        <div class="instructions-text"></div>
                    </div>
                `}

    ${instructions ? `
                    <div class="medication-item">
                        <div class="instructions-text">Additional Instructions: ${instructions}</div>
    </div>
    ` : ''}

    ${warnings ? `
                    <div class="medication-item">
                        <div class="instructions-text">Warnings: ${warnings}</div>
    </div>
    ` : ''}
            </div>
        </div>

        <div class="footer-section">
            <div class="footer-row">
                <div class="refill-section">
                    <span>□ Label</span>
                    <div class="refill-line">Refill - NR - 1 - 2 - 3 - 4 - PRN</div>
                </div>
                <div class="doctor-signature">
                    ${appointmentInfo.doctorName || '________________'}
                </div>
            </div>
        </div>

        <div class="disclaimer">
            KEEP OUT OF CHILDREN'S REACH • FOR VETERINARY USE ONLY
        </div>
            </div>
        </div>
        
        <div class="separator-line"></div>
        
        <!-- Second Copy -->
        <div class="prescription-copy">
            <div class="prescription-form">
                <div class="paw-print">
                    <svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
                        <path fill="currentColor" d="M234.5 92.9c14.3 42.9-.3 86.2-32.6 96.8s-70.1-15.6-84.4-58.5s.3-86.2 32.6-96.8s70.1 15.6 84.4 58.5M100.4 198.6c18.9 32.4 14.3 70.1-10.2 84.1s-59.7-.9-78.5-33.3s-14.3-70.1 10.2-84.1s59.7.9 78.5 33.3M69.2 401.2C121.6 259.9 214.7 224 256 224s134.4 35.9 186.8 177.2c3.6 9.7 5.2 20.1 5.2 30.5v1.6c0 25.8-20.9 46.7-46.7 46.7c-11.5 0-22.9-1.4-34-4.2l-88-22c-15.3-3.8-31.3-3.8-46.6 0l-88 22c-11.1 2.8-22.5 4.2-34 4.2c-25.8 0-46.7-20.9-46.7-46.7v-1.6c0-10.4 1.6-20.8 5.2-30.5m352.6-118.5c-24.5-14-29.1-51.7-10.2-84.1s54-47.3 78.5-33.3s29.1 51.7 10.2 84.1s-54 47.3-78.5 33.3m-111.7-93c-32.3-10.6-46.9-53.9-32.6-96.8s52.1-69.1 84.4-58.5s46.9 53.9 32.6 96.8s-52.1 69.1-84.4 58.5"/>
                    </svg>
                </div>
        
        <div class="header">
            <div class="office-name">Provincial Veterinary Office of Oriental Mindoro</div>
            <div class="office-address">Capitol Complex, Calapan City, Or.Mindoro</div>
            <div class="office-email">provet_ormdo@yahoo.com</div>
            <div class="office-phone">Phone: (043) 288 7743</div>
        </div>

        <div class="client-section">
            <div class="client-row">
                <span class="client-label">Client Name:</span>
                <div class="client-input">${appointmentInfo.clientName || ''}</div>
            </div>
            <div class="client-row">
                <span class="client-label">Address:</span>
                <div class="client-input">${appointmentInfo.clientAddress || ''}</div>
            </div>
            <div class="client-row">
                <span class="client-label">Patient/Pet Name:</span>
                <div class="client-input">${appointmentInfo.petName || ''}</div>
            </div>
            <div class="client-row-inline">
                <div class="client-inline">
                    <span class="client-label">Age:</span>
                    <div class="client-input">${appointmentInfo.petAge || ''}</div>
                </div>
                <div class="client-inline">
                    <span class="client-label">Date:</span>
                    <div class="client-input">${appointmentInfo.date || ''}</div>
                </div>
            </div>
        </div>

        <div class="rx-section">
            <div class="rx-symbol">℞</div>
            <div class="prescription-content">
                ${medications.length > 0 ? medications.map((med, index) => `
                    <div class="medication-item">
                        <div class="medication-name">${med.name || 'Medication Name'}</div>
                        <div class="medication-details">
                            ${med.dosage ? `Dosage: ${med.dosage}` : ''}
                            ${med.frequency ? ` • Frequency: ${med.frequency}` : ''}
                            ${med.duration ? ` • Duration: ${med.duration}` : ''}
                        </div>
                        ${med.instructions ? `<div class="instructions-text">Instructions: ${med.instructions}</div>` : ''}
                    </div>
                `).join('') : `
                    <div class="medication-item">
                        <div class="medication-name">Medication Name</div>
                        <div class="medication-details"></div>
                        <div class="instructions-text"></div>
                    </div>
                `}
                
                ${instructions ? `
                    <div class="medication-item">
                        <div class="instructions-text">Additional Instructions: ${instructions}</div>
    </div>
    ` : ''}

                ${warnings ? `
                    <div class="medication-item">
                        <div class="instructions-text">Warnings: ${warnings}</div>
                    </div>
                ` : ''}
            </div>
        </div>

        <div class="footer-section">
            <div class="footer-row">
                <div class="refill-section">
                    <span>□ Label</span>
                    <div class="refill-line">Refill - NR - 1 - 2 - 3 - 4 - PRN</div>
                </div>
                <div class="doctor-signature">
                    ${appointmentInfo.doctorName || '________________'}
                </div>
            </div>
        </div>

        <div class="disclaimer">
            KEEP OUT OF CHILDREN'S REACH • FOR VETERINARY USE ONLY
        </div>
            </div>
        </div>
    </div>
</body>
</html>`;
  };

        // Schedule Follow-up - Simple navigation to appointment creation
   // Handle creating new appointment for reschedule requests
  const createNewAppointment = (appointment) => {
    console.log('Creating new appointment for reschedule request:', appointment.id);
    // Navigate to appointment creation page
    router.push('/user/userappointments');
    // Close the history panel after navigation
    closeHistory();
  };

  
  // Fetch appointments when component is mounted
  onMounted(async () => {
    // Add click outside handler for action menus
    const handleClickOutside = (event) => {
      if (!event.target.closest('.action-menu-container')) {
        closeActionMenu();
      }
    };
    
    document.addEventListener('click', handleClickOutside);
    
    // Cleanup function
    onUnmounted(() => {
      document.removeEventListener('click', handleClickOutside);
      // Ensure body scrolling is restored when component unmounts
      document.body.classList.remove('modal-open');
    });

    // Smart loading - always fetch data on mount
    if (!authStore.user?.userId) {
      return;
    }

    try {
      // Always fetch data on mount - the fetchUserAppointments function will handle caching
      console.log('HistoryPanel: Fetching appointment data on mount');
      await fetchUserAppointments();
    } catch (error) {
      console.error('Error in HistoryPanel onMounted:', error);
      // Fallback to regular fetch
      await fetchUserAppointments();
    }
  });
  
  // Watch for changes in panel visibility
  watch(() => props.isVisible, async (newValue) => {
    isVisibleRef.value = newValue;
    if (isVisibleRef.value && authStore.user) {
      // Only fetch if we don't have data
      if (appointments.value.length === 0) {
        console.log('Panel became visible, fetching appointment data');
        await fetchUserAppointments();
      } else {
        console.log('Panel became visible, using existing appointment data');
      }
    }
  });
  </script>
  
<style scoped>
/* Modal body scroll prevention */
:global(.modal-open) {
  overflow: hidden !important;
  position: fixed !important;
  width: 100% !important;
  height: 100% !important;
  top: 0 !important;
  left: 0 !important;
  right: 0 !important;
  bottom: 0 !important;
  touch-action: none !important;
  -webkit-overflow-scrolling: touch !important;
}

/* Additional modal isolation */
:global(.modal-open *) {
  pointer-events: none !important;
}

:global(.modal-open .fixed) {
  pointer-events: auto !important;
}

:global(.modal-open .fixed *) {
  pointer-events: auto !important;
}

/* Override AppointmentFeedback component styling to match modal design */
.feedback-content :deep(.bg-white) {
  background: transparent !important;
  box-shadow: none !important;
  border-radius: 0 !important;
  padding: 0 !important;
  max-width: none !important;
  margin: 0 !important;
}

.feedback-content :deep(.rounded-lg) {
  border-radius: 0 !important;
}

.feedback-content :deep(.shadow-lg) {
  box-shadow: none !important;
}

/* Override button styling to match modal design */
.feedback-content :deep(.flex.space-x-3) {
  margin-top: 1.5rem !important;
  padding-top: 1rem !important;
  border-top: 1px solid #e5e7eb !important;
  gap: 0.5rem !important;
}

.feedback-content :deep(.flex.space-x-3 button) {
  border-radius: 9999px !important;
  padding: 0.375rem 0.75rem !important;
  font-size: 0.75rem !important;
  line-height: 1rem !important;
}

.feedback-content :deep(.flex.space-x-3 button:first-child),
.feedback-content :deep(.flex.space-x-3 button:first-of-type) {
  background-color: #fecaca !important;
  color: #991b1b !important;
  border: none !important;
}

.feedback-content :deep(.flex.space-x-3 button:first-child:hover),
.feedback-content :deep(.flex.space-x-3 button:first-of-type:hover) {
  background-color: #fca5a5 !important;
}

.feedback-content :deep(.flex.space-x-3 button:last-child:not(:only-child)) {
  background-color: #3b82f6 !important;
  color: white !important;
  border: none !important;
}

.feedback-content :deep(.flex.space-x-3 button:last-child:not(:only-child):hover) {
  background-color: #1d4ed8 !important;
}

.feedback-content :deep(.flex.space-x-3 button:last-child:disabled) {
  opacity: 0.5 !important;
  cursor: not-allowed !important;
}

/* Override other rounded elements */
.feedback-content :deep(.border-gray-200) {
  border-radius: 0.5rem !important;
}

.feedback-content :deep(.bg-gray-50) {
  border-radius: 0.5rem !important;
}
</style>
  