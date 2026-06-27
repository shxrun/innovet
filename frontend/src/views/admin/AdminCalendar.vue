<template>
  <div class="p-3 sm:p-4 md:p-6 bg-white rounded-2xl">
    <!-- Header Section -->
    <div class="mb-6 sm:mb-8">
      <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between mb-4 sm:mb-6 gap-4">
        <div>
          <h1 class="text-xl sm:text-2xl font-semibold text-gray-900">Appointment Calendar</h1>
          <p class="text-sm sm:text-base text-gray-500 mt-1">Manage and track patient appointments with ease</p>
        </div>
      </div>
    </div>
        
    <!-- Calendar View -->
    <div ref="calendarRef" class="bg-white rounded-lg border border-gray-200 overflow-hidden">
      <!-- Calendar Controls -->
      <div class="p-4 sm:p-6 border-b border-gray-200">
        <div class="flex flex-col lg:flex-row lg:justify-between lg:items-start gap-4">
          <!-- Month Navigation -->
          <div class="flex items-center gap-1 sm:gap-2 md:gap-4">
            <button 
              @click="prevMonth"
              :disabled="loading"
              class="p-1.5 sm:p-2 border border-gray-200 rounded-lg hover:bg-gray-50 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <svg class="w-3 h-3 sm:w-4 sm:h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
              </svg>
            </button>
            
            <div class="text-sm sm:text-lg md:text-xl font-semibold text-gray-900">
              {{ currentMonth }}
            </div>

            <button 
              @click="nextMonth"
              :disabled="loading"
              class="p-1.5 sm:p-2 border border-gray-200 rounded-lg hover:bg-gray-50 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <svg class="w-3 h-3 sm:w-4 sm:h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
              </svg>
            </button>
            
            <button 
              @click="goToToday"
              :disabled="loading"
              class="px-2 sm:px-3 md:px-4 py-1.5 sm:py-2 text-xs font-medium bg-blue-500 text-white rounded-full hover:bg-blue-600 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span class="hidden sm:inline">Go to Today</span>
              <span class="sm:hidden">Today</span>
            </button>
          </div>

          <!-- Right Side Controls -->
          <div class="flex flex-col gap-3">
            <!-- Combined Filter and View Controls -->
            <div class="flex items-center justify-between gap-2">
              <!-- Show Filter (Left) -->
              <div class="flex items-center gap-1 sm:gap-2">
                <span class="text-xs font-medium text-gray-700">Show:</span>
                <button
                  @click="showExpired = false"
                  :disabled="loading"
                  :class="[
                    'px-2 sm:px-3 md:px-4 py-1.5 sm:py-2 rounded-full text-xs font-medium transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed',
                    !showExpired ? 'bg-blue-500 text-white hover:bg-blue-600' : 'bg-white text-gray-600 border border-gray-200 hover:bg-gray-50'
                  ]"
                >
                  <span class="hidden sm:inline">Upcoming Only</span>
                  <span class="sm:hidden">Upcoming</span>
                </button>
                <button
                  @click="showExpired = true"
                  :disabled="loading"
                  :class="[
                    'px-2 sm:px-3 md:px-4 py-1.5 sm:py-2 rounded-full text-xs font-medium transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed',
                    showExpired ? 'bg-blue-500 text-white hover:bg-blue-600' : 'bg-white text-gray-600 border border-gray-200 hover:bg-gray-50'
                  ]"
                >
                  <span class="hidden sm:inline">All Appointments</span>
                  <span class="sm:hidden">All</span>
                </button>
              </div>
              
              <!-- View Toggle Buttons (Right) -->
              <div class="flex items-center gap-1 sm:gap-2">
                <span class="text-xs font-medium text-gray-700">View:</span>
                <div class="flex bg-gray-100 rounded-full p-0.5">
                  <button
                    @click="viewMode = 'grid'"
                    :class="[
                      'flex items-center gap-1 px-2 sm:px-3 md:px-4 py-1.5 sm:py-2 rounded-full text-xs font-medium transition-all duration-200',
                      viewMode === 'grid' ? 'bg-white text-blue-600 shadow-sm' : 'text-gray-600 hover:text-gray-800'
                    ]"
                  >
                    <Grid3X3 class="w-3 h-3" />
                    <span class="hidden sm:inline">Grid</span>
                  </button>
                  <button
                    @click="viewMode = 'list'"
                    :class="[
                      'flex items-center gap-1 px-2 sm:px-3 md:px-4 py-1.5 sm:py-2 rounded-full text-xs font-medium transition-all duration-200',
                      viewMode === 'list' ? 'bg-white text-blue-600 shadow-sm' : 'text-gray-600 hover:text-gray-800'
                    ]"
                  >
                    <List class="w-3 h-3" />
                    <span class="hidden sm:inline">List</span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
        



        

          </div>
          
      <!-- Calendar Grid -->
      <div class="overflow-hidden">
        <!-- Loading State -->
        <div v-if="loading" class="p-4 sm:p-6">
          <!-- Skeleton Calendar -->
          <div class="bg-white rounded-lg border border-gray-200 overflow-hidden">
            <!-- Skeleton Calendar Header -->
            <div class="bg-gray-50 p-3 sm:p-4 border-b border-gray-200">
              <div class="flex items-center justify-between mb-3 sm:mb-4">
                <div class="animate-pulse">
                  <div class="h-5 sm:h-6 bg-gray-200 rounded w-24 sm:w-32 mb-2"></div>
                  <div class="h-3 sm:h-4 bg-gray-200 rounded w-32 sm:w-48"></div>
                </div>
                <div class="flex items-center gap-2">
                  <div class="animate-pulse w-6 sm:w-8 h-6 sm:h-8 bg-gray-200 rounded-lg"></div>
                  <div class="animate-pulse w-12 sm:w-16 h-6 sm:h-8 bg-gray-200 rounded-lg"></div>
                  <div class="animate-pulse w-6 sm:w-8 h-6 sm:h-8 bg-gray-200 rounded-lg"></div>
                </div>
              </div>
            </div>

            <!-- Grid View Skeleton -->
            <div v-if="viewMode === 'grid'">
              <!-- Skeleton Days of Week -->
              <div class="grid grid-cols-7 bg-gray-50 border-b border-gray-200">
                <div v-for="i in 7" :key="i" class="p-2 sm:p-3 text-center border-r border-gray-200 last:border-r-0">
                  <div class="animate-pulse h-3 sm:h-4 bg-gray-200 rounded w-6 sm:w-8 mx-auto"></div>
                </div>
              </div>

              <!-- Skeleton Calendar Days -->
              <div class="grid grid-cols-7">
                <div v-for="i in 42" :key="i" class="min-h-[80px] sm:min-h-[100px] md:min-h-[120px] border-r border-b border-gray-200 last:border-r-0 relative">
                  <div class="p-1 sm:p-2">
                    <div class="animate-pulse h-3 sm:h-4 bg-gray-200 rounded w-4 sm:w-6 mb-1 sm:mb-2"></div>
                  </div>
                  <div class="px-1 pb-1 space-y-0.5 sm:space-y-1">
                    <div v-for="j in 2" :key="j" class="animate-pulse">
                      <div class="h-6 sm:h-8 md:h-12 bg-gray-200 rounded-md mb-1"></div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- List View Skeleton -->
            <div v-else-if="viewMode === 'list'" class="divide-y divide-gray-200">
              <div v-for="i in 7" :key="i" class="p-3 sm:p-4">
                <div class="animate-pulse">
                  <!-- Date Header Skeleton -->
                  <div class="flex items-center justify-between mb-3">
                    <div class="flex items-center gap-3">
                      <div class="flex flex-col items-center">
                        <div class="h-3 bg-gray-200 rounded w-6 mb-1"></div>
                        <div class="h-5 bg-gray-200 rounded w-6"></div>
                      </div>
                      <div class="flex-1">
                        <div class="h-4 bg-gray-200 rounded w-32 mb-1"></div>
                        <div class="h-3 bg-gray-200 rounded w-16"></div>
                      </div>
                    </div>
                    <div class="h-3 bg-gray-200 rounded w-20"></div>
                  </div>
                  
                  <!-- Appointments Skeleton -->
                  <div class="space-y-2">
                    <div v-for="j in 2" :key="j" class="p-2 sm:p-3 rounded-lg border border-gray-200">
                      <div class="flex items-start justify-between">
                        <div class="flex-1">
                          <div class="flex items-center gap-2 mb-1">
                            <div class="w-2 h-2 bg-gray-200 rounded-full"></div>
                            <div class="h-4 bg-gray-200 rounded w-24"></div>
                            <div class="h-3 bg-gray-200 rounded w-16"></div>
                          </div>
                          <div class="flex items-center gap-3 mb-1">
                            <div class="h-3 bg-gray-200 rounded w-20"></div>
                            <div class="h-3 bg-gray-200 rounded w-24"></div>
                            <div class="h-3 bg-gray-200 rounded w-16"></div>
                          </div>
                          <div class="h-3 bg-gray-200 rounded w-32"></div>
                        </div>
                        <div class="h-5 bg-gray-200 rounded-full w-16"></div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
          
        <!-- Empty State -->
        <div v-else-if="appointments.length === 0" class="p-4 sm:p-8 text-center">
          <div class="w-16 sm:w-20 h-16 sm:h-20 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-3 sm:mb-4">
            <CalendarIcon class="w-8 sm:w-10 h-8 sm:h-10 text-gray-400" />
          </div>
          <h3 class="text-base sm:text-lg font-semibold text-gray-700 mb-1 sm:mb-2">No Upcoming Appointments</h3>
          <p class="text-sm sm:text-base text-gray-500 mb-3 sm:mb-4">There are no appointments scheduled for today or the future.</p>
        </div>

        <!-- Calendar Content -->
        <div v-else>
          <!-- Grid View -->
          <div v-if="viewMode === 'grid'" class="bg-white rounded-lg border border-gray-200 overflow-hidden">
            <!-- Calendar Header -->
            <div class="bg-gray-50 p-3 sm:p-4 border-b border-gray-200">
              <div class="flex items-center justify-between mb-3 sm:mb-4">
                <div>
                  <h3 class="text-lg sm:text-xl font-bold text-gray-900">{{ currentMonth }}</h3>
                  <p class="text-xs sm:text-sm text-gray-600">Appointment Calendar</p>
                </div>
                <div class="flex items-center gap-2">
                  <button 
                    @click="prevMonth"
                    class="p-2 rounded-lg hover:bg-gray-100 transition-colors duration-200"
                  >
                    <svg class="w-4 sm:w-5 h-4 sm:h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
                    </svg>
                  </button>
                  <button 
                    @click="goToToday"
                    class="px-3 sm:px-4 py-2 bg-blue-500 text-white rounded-full hover:bg-blue-600 transition-colors duration-200 text-xs sm:text-sm font-medium"
                  >
                    Today
                  </button>
                  <button 
                    @click="nextMonth"
                    class="p-2 rounded-lg hover:bg-gray-100 transition-colors duration-200"
                  >
                    <svg class="w-4 sm:w-5 h-4 sm:h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                    </svg>
                  </button>
                </div>
              </div>
            </div>

            <!-- Days of Week Header -->
            <div class="grid grid-cols-7 bg-gray-50 border-b border-gray-200">
              <div 
                v-for="dayName in ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']" 
                :key="dayName"
                class="p-2 sm:p-3 text-center border-r border-gray-200 last:border-r-0"
              >
                <span class="text-xs sm:text-sm font-semibold text-gray-700">{{ dayName }}</span>
              </div>
            </div>

            <!-- Calendar Days Grid -->
            <div class="grid grid-cols-7">
              <div 
                v-for="day in calendarDays" 
                :key="day.date"
                class="min-h-[80px] sm:min-h-[100px] md:min-h-[120px] border-r border-b border-gray-200 last:border-r-0 relative"
                :class="[
                  day.isToday ? 'bg-blue-50' : 'bg-white',
                  day.isCurrentMonth ? '' : 'bg-gray-50/50'
                ]"
              >
                <!-- Date Number -->
                <div class="p-1 sm:p-2">
                  <div class="flex items-center gap-1">
                    <span 
                      class="text-xs sm:text-sm font-medium"
                      :class="[
                        day.isToday ? 'bg-blue-600 text-white rounded-full w-5 sm:w-6 h-5 sm:h-6 flex items-center justify-center' : '',
                        day.isCurrentMonth ? 'text-gray-800' : 'text-gray-400'
                      ]"
                    >
                      {{ day.dayNumber }}
                    </span>
                    <span v-if="day.isToday" class="text-[10px] sm:text-xs text-blue-600 font-medium">Today</span>
                  </div>
                </div>

                <!-- Appointments for this day -->
                <div class="px-1 pb-1 space-y-0.5 sm:space-y-1">
                  <div 
                    v-for="appt in getAppointmentsForDay(day.date)"
                    :key="appt.id"
                    class="group p-1 sm:p-1.5 rounded-md cursor-pointer hover:shadow-sm transition-all duration-200 text-[9px] sm:text-[10px] md:text-xs"
                    :class="[
                      appt.isExpired ? 'bg-gray-100 border border-gray-200 opacity-70' : 
                      appt.isCurrent ? 'bg-green-100 border border-green-200 shadow-sm' :
                      'bg-blue-100 border border-blue-200 hover:bg-blue-200'
                    ]"
                    @click="openAppointmentDetails(appt)"
                  >
                    <div class="flex items-center gap-1 mb-0.5 sm:mb-1">
                      <div class="w-1 sm:w-1.5 h-1 sm:h-1.5 rounded-full flex-shrink-0" 
                           :class="appt.isExpired ? 'bg-gray-400' : 
                                  appt.isCurrent ? 'bg-green-500' : 
                                  'bg-blue-500'">
                      </div>
                      <span class="font-semibold text-gray-800 truncate text-[8px] sm:text-[9px] md:text-[10px] max-w-[40px] sm:max-w-none">{{ appt.originalTime.split('-')[0].trim() }}</span>
                    </div>
                    <div class="text-gray-700 font-medium truncate text-[8px] sm:text-[9px] md:text-[10px] max-w-[50px] sm:max-w-none">{{ appt.petName }}</div>
                    <div class="text-gray-600 truncate text-[7px] sm:text-[8px] md:text-[9px] hidden sm:block">{{ appt.doctorName }}</div>
                    <div class="flex items-center justify-between mt-0.5 sm:mt-1">
                      <span class="text-[7px] sm:text-[8px] md:text-[9px] px-1 py-0.5 rounded truncate max-w-[45px] sm:max-w-none" 
                            :class="appt.isExpired ? 'bg-gray-200 text-gray-600' :
                                   appt.isCurrent ? 'bg-green-200 text-green-700' :
                                   'bg-blue-200 text-blue-700'"
                            :title="appt.status">
                        {{ appt.status.length > 6 ? appt.status.substring(0, 6) + '...' : appt.status }}
                      </span>
                      <span class="text-[7px] sm:text-[8px] md:text-[9px] text-gray-500 hidden sm:inline truncate max-w-[30px] sm:max-w-none">{{ appt.type }}</span>
                    </div>
                  </div>
                </div>

                <!-- More appointments indicator -->
                <div v-if="getAppointmentsForDay(day.date).length > 2" class="absolute bottom-0.5 sm:bottom-1 right-0.5 sm:right-1">
                  <span class="text-[7px] sm:text-[8px] md:text-[9px] text-blue-600 font-medium bg-blue-100 px-1 py-0.5 rounded">
                    +{{ getAppointmentsForDay(day.date).length - 2 }}
                  </span>
                </div>
      </div>
            </div>
          </div>
          
          <!-- List View -->
          <div v-else-if="viewMode === 'list'" class="bg-white rounded-lg border border-gray-200 overflow-hidden">
            <!-- List Header -->
            <div class="bg-gray-50 p-3 sm:p-4 border-b border-gray-200">
              <div class="flex items-center justify-between mb-3 sm:mb-4">
                <div>
                  <h3 class="text-lg sm:text-xl font-bold text-gray-900">{{ currentMonth }}</h3>
                  <p class="text-sm text-gray-500">Calendar List View</p>
                </div>
                <button 
                  @click="goToToday"
                  class="px-3 sm:px-4 py-2 bg-blue-500 text-white rounded-full hover:bg-blue-600 transition-colors duration-200 text-xs sm:text-sm font-medium"
                >
                  Today
                </button>
              </div>
            </div>
            
            <!-- Calendar Days List -->
            <div class="divide-y divide-gray-200">
              <div 
                v-for="day in calendarDays" 
                :key="day.date"
                class="p-3 sm:p-4"
                :class="[
                  day.isToday ? 'bg-blue-50' : 'bg-white',
                  day.isCurrentMonth ? '' : 'bg-gray-50/50'
                ]"
              >
                <!-- Date Header -->
                <div class="flex items-center justify-between mb-2 sm:mb-3">
                  <div class="flex items-center gap-3">
                    <div class="flex flex-col items-center">
                      <span class="text-xs sm:text-sm font-medium text-gray-500 uppercase">
                        {{ format(new Date(day.date), 'EEE') }}
                      </span>
                      <span 
                        class="text-lg sm:text-xl font-bold"
                        :class="day.isToday ? 'text-blue-600' : 'text-gray-900'"
                      >
                        {{ format(new Date(day.date), 'd') }}
                      </span>
                    </div>
                    <div class="flex-1">
                      <div class="text-sm sm:text-base font-medium text-gray-900">
                        {{ format(new Date(day.date), 'MMMM d, yyyy') }}
                      </div>
                      <div v-if="day.isToday" class="text-xs text-blue-600 font-medium">Today</div>
                    </div>
                  </div>
                  <div class="text-xs sm:text-sm text-gray-500">
                    {{ getAppointmentsForDay(day.date).length }} appointment{{ getAppointmentsForDay(day.date).length !== 1 ? 's' : '' }}
                  </div>
                </div>
                
                <!-- Appointments for this day -->
                <div v-if="getAppointmentsForDay(day.date).length > 0" class="space-y-2">
                  <div 
                    v-for="appt in getAppointmentsForDay(day.date)"
                    :key="appt.id"
                    class="p-2 sm:p-3 rounded-lg border cursor-pointer hover:shadow-sm transition-all duration-200"
                    :class="[
                      appt.isExpired ? 'bg-gray-100 border-gray-200 opacity-70' : 
                      appt.isCurrent ? 'bg-green-100 border-green-200' :
                      'bg-blue-100 border-blue-200 hover:bg-blue-200'
                    ]"
                    @click="openAppointmentDetails(appt)"
                  >
                    <div class="flex items-start justify-between">
                      <div class="flex-1 min-w-0">
                        <div class="flex items-center gap-2 mb-1">
                          <div class="w-2 h-2 rounded-full flex-shrink-0" 
                               :class="appt.isExpired ? 'bg-gray-400' : 
                                      appt.isCurrent ? 'bg-green-500' : 
                                      'bg-blue-500'">
                          </div>
                          <span class="text-sm sm:text-base font-semibold text-gray-900">{{ appt.petName }}</span>
                          <span class="text-xs sm:text-sm text-gray-500">{{ appt.type }}</span>
                        </div>
                        <div class="flex items-center gap-3 text-xs sm:text-sm text-gray-600 mb-1">
                          <div class="flex items-center gap-1">
                            <ClockIcon class="w-3 h-3 sm:w-4 sm:h-4" />
                            <span>{{ appt.originalTime }}</span>
                          </div>
                          <div class="flex items-center gap-1">
                            <UserIcon class="w-3 h-3 sm:w-4 sm:h-4" />
                            <span>{{ appt.doctorName }}</span>
                          </div>
                          <div class="flex items-center gap-1">
                            <PawPrintIcon class="w-3 h-3 sm:w-4 sm:h-4" />
                            <span>{{ appt.petType }}</span>
                          </div>
                        </div>
                        <div class="text-xs sm:text-sm text-gray-500">
                          Owner: {{ appt.ownerName }}
                        </div>
                      </div>
                      <div class="flex flex-col items-end gap-1">
                        <span class="text-xs px-2 py-1 rounded-full font-medium" 
                              :class="appt.isExpired ? 'bg-gray-200 text-gray-600' :
                                     appt.isCurrent ? 'bg-green-200 text-green-700' :
                                     'bg-blue-200 text-blue-700'">
                          {{ appt.status }}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
                
                <!-- No appointments for this day -->
                <div v-else class="text-center py-2 sm:py-3">
                  <span class="text-xs sm:text-sm text-gray-400">No appointments</span>
                </div>
              </div>
            </div>
            
            <!-- Empty List State -->
            <div v-if="filteredAppointments.length === 0" class="p-6 sm:p-8 text-center">
              <CalendarIcon class="w-12 h-12 sm:w-16 sm:h-16 text-gray-300 mx-auto mb-3 sm:mb-4" />
              <h3 class="text-base sm:text-lg font-semibold text-gray-700 mb-1 sm:mb-2">No Appointments Found</h3>
              <p class="text-sm sm:text-base text-gray-500">No appointments match your current filter settings.</p>
            </div>
          </div>
        </div>
      </div>
  </div>

    <!-- Appointment Details Modal -->
    <div v-if="selectedAppointment" 
         class="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-start justify-center pt-16 sm:pt-20 z-50"
         @click="selectedAppointment = null">
      <div class="bg-white rounded-2xl w-full max-w-md mx-4 sm:mx-0 shadow-2xl border border-gray-200" @click.stop>
        <div class="p-4 sm:p-6">
          <div class="flex justify-between items-start mb-4 sm:mb-6">
            <div>
              <div class="flex items-center gap-2 text-xs sm:text-sm text-gray-500 mb-2">
                <span>Appointment ID</span>
                <span class="font-mono bg-gray-100 px-2 py-1 rounded text-xs">{{ selectedAppointment.id }}</span>
              </div>
              <div class="flex items-center gap-3">
                <div :class="[
                  'w-2 sm:w-3 h-2 sm:h-3 rounded-full',
                  getAppointmentStatusClass(selectedAppointment.status)
                ]"></div>
                <h3 class="text-lg sm:text-xl font-bold text-gray-900">{{ selectedAppointment.petName }}</h3>
              </div>
            </div>
            <button @click="selectedAppointment = null" class="text-gray-400 hover:text-gray-600 hover:scale-110 transition-all duration-200">
              <svg class="w-5 sm:w-6 h-5 sm:h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
              </svg>
            </button>
          </div>

          <div class="space-y-4 sm:space-y-6">
            <div class="flex items-center gap-3 sm:gap-4 p-3 sm:p-4 bg-gray-50 rounded-xl border border-gray-200">
              <div class="w-10 sm:w-12 h-10 sm:h-12 rounded-full bg-blue-500 flex items-center justify-center">
                <svg class="w-5 sm:w-6 h-5 sm:h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"></path>
                </svg>
              </div>
              <div>
                <div class="text-xs sm:text-sm font-medium text-gray-500 mb-1">Pet Information</div>
                <div class="text-sm sm:text-base font-bold text-gray-900">{{ selectedAppointment.petName }} ({{ selectedAppointment.petType }})</div>
              </div>
            </div>

            <div class="flex items-center gap-3 sm:gap-4 p-3 sm:p-4 bg-gray-50 rounded-xl border border-gray-200">
              <div class="w-10 sm:w-12 h-10 sm:h-12 rounded-full bg-green-500 flex items-center justify-center">
                <svg class="w-5 sm:w-6 h-5 sm:h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                </svg>
              </div>
              <div>
                <div class="text-xs sm:text-sm font-medium text-gray-500 mb-1">Owner</div>
                <div class="text-sm sm:text-base font-bold text-gray-900">{{ selectedAppointment.ownerName }}</div>
              </div>
            </div>

            <div class="flex items-center gap-3 sm:gap-4 p-3 sm:p-4 bg-gray-50 rounded-xl border border-gray-200">
              <div class="w-10 sm:w-12 h-10 sm:h-12 rounded-full bg-purple-500 flex items-center justify-center">
                <ClockIcon class="w-5 sm:w-6 h-5 sm:h-6 text-white" />
              </div>
              <div>
                <div class="text-xs sm:text-sm font-medium text-gray-500 mb-1">Appointment</div>
                <div class="text-sm sm:text-base font-bold text-gray-900">{{ selectedAppointment.date }}, {{ formatTime(selectedAppointment.time) }}</div>
                <div class="text-xs sm:text-sm text-gray-500">Duration: {{ selectedAppointment.duration }} minutes</div>
              </div>
            </div>

            <div class="flex items-center gap-3 sm:gap-4 p-3 sm:p-4 bg-gray-50 rounded-xl border border-gray-200">
              <div class="w-10 sm:w-12 h-10 sm:h-12 rounded-full bg-orange-500 flex items-center justify-center">
                <component :is="selectedAppointment.type === 'Online' ? VideoIcon : Footprints" class="w-5 sm:w-6 h-5 sm:h-6 text-white" />
              </div>
              <div>
                <div class="text-xs sm:text-sm font-medium text-gray-500 mb-1">Type</div>
                <div class="text-sm sm:text-base font-bold text-gray-900">{{ selectedAppointment.type }}</div>
                <div v-if="selectedAppointment.type === 'Online'" class="text-xs sm:text-sm text-blue-600 hover:underline">
                  <a :href="selectedAppointment.videoLink" target="_blank" rel="noopener noreferrer">Join Video Call</a>
                </div>
              </div>
            </div>

            <div class="border-t border-gray-200 pt-4 sm:pt-6">
              <div class="text-xs sm:text-sm font-medium text-gray-500 mb-2">Notes</div>
              <p class="text-xs sm:text-sm text-gray-700 bg-gray-50 p-3 rounded-lg">{{ selectedAppointment.notes }}</p>
            </div>

            <div class="border-t border-gray-200 pt-4 sm:pt-6">
              <button class="text-xs sm:text-sm font-medium text-blue-600 hover:text-blue-700 transition-colors duration-200">
                See Patient History →
              </button>
            </div>
          </div>
        </div>

        <div class="flex border-t border-gray-200">
          <button class="flex-1 px-3 sm:px-4 py-3 sm:py-4 text-xs sm:text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors duration-200">
            Edit
          </button>
          <button class="flex-1 px-3 sm:px-4 py-3 sm:py-4 text-xs sm:text-sm font-medium text-white bg-red-500 hover:bg-red-600 border-l border-gray-200 transition-colors duration-200">
            Cancel
          </button>
        </div>
      </div>
    </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useRouter } from 'vue-router';
import {
  ClockIcon,
  VideoIcon,
  Footprints,
  CalendarIcon,
  XIcon,
  PawPrintIcon,
  UserIcon,
  Grid3X3,
  List
} from 'lucide-vue-next';
import { useAppointmentStore } from '@/stores/modules/appointmentStore';
import { format, isToday, isThisWeek, isThisMonth, parseISO, isBefore, startOfWeek, endOfWeek, eachDayOfInterval } from 'date-fns';
import { Timestamp } from 'firebase/firestore';

const router = useRouter();
const appointmentStore = useAppointmentStore();

const selectedAppointment = ref(null);
const currentDate = ref(new Date());
const calendarRef = ref(null);
const loading = ref(false);
const showExpired = ref(false);
const viewMode = ref('grid'); // 'grid', 'list'







// Real appointments data
const appointments = ref([]);

const currentMonth = computed(() => {
  return currentDate.value.toLocaleString('default', { month: 'long', year: 'numeric' });
});

// Calendar navigation functions
const prevMonth = () => {
  const newDate = new Date(currentDate.value);
  newDate.setMonth(newDate.getMonth() - 1);
  currentDate.value = newDate;
};

const nextMonth = () => {
  const newDate = new Date(currentDate.value);
  newDate.setMonth(newDate.getMonth() + 1);
  currentDate.value = newDate;
};

const goToToday = () => {
  currentDate.value = new Date();
};

// Calendar days computation
const calendarDays = computed(() => {
  const year = currentDate.value.getFullYear();
  const month = currentDate.value.getMonth();
  
  // Get first day of the month
  const firstDay = new Date(year, month, 1);
  // Get last day of the month
  const lastDay = new Date(year, month + 1, 0);
  
  // Get the day of week for the first day (0 = Sunday, 1 = Monday, etc.)
  const firstDayOfWeek = firstDay.getDay();
  
  // Get the total number of days in the month
  const daysInMonth = lastDay.getDate();
  
  const days = [];
  
  // Add days from previous month to fill the first week
  for (let i = firstDayOfWeek - 1; i >= 0; i--) {
    const date = new Date(year, month, -i);
    days.push({
      date: date.toDateString(),
      dayNumber: date.getDate(),
      isCurrentMonth: false,
      isToday: date.toDateString() === new Date().toDateString()
    });
  }
  
  // Add days of current month
  for (let day = 1; day <= daysInMonth; day++) {
    const date = new Date(year, month, day);
    days.push({
      date: date.toDateString(),
      dayNumber: day,
      isCurrentMonth: true,
      isToday: date.toDateString() === new Date().toDateString()
    });
  }
  
  // Add days from next month to fill the last week
  const remainingDays = 42 - days.length; // 6 rows * 7 days = 42
  for (let day = 1; day <= remainingDays; day++) {
    const date = new Date(year, month + 1, day);
    days.push({
      date: date.toDateString(),
      dayNumber: day,
      isCurrentMonth: false,
      isToday: date.toDateString() === new Date().toDateString()
    });
  }
  
  return days;
});

// Function to get appointments for a specific day
const getAppointmentsForDay = (dateString) => {
  const appointments = filteredAppointments.value.filter(appt => {
    const apptDate = appt.date instanceof Date ? appt.date : new Date(appt.date);
    return apptDate.toDateString() === dateString;
  });
  
  // In grid view, show only 2 appointments. In list view, show all appointments
  return viewMode.value === 'grid' ? appointments.slice(0, 2) : appointments;
};



// Fetch appointments from Firebase
const fetchAppointments = async () => {
  loading.value = true;
  try {
    // Import Firebase functions
    const { getFirestore, collection, getDocs, query, where, orderBy, Timestamp } = await import('firebase/firestore');
    const db = getFirestore();
    
    // Get current month range
    const currentMonth = currentDate.value.getMonth();
    const currentYear = currentDate.value.getFullYear();
    const startOfMonth = new Date(currentYear, currentMonth, 1);
    const endOfMonth = new Date(currentYear, currentMonth + 1, 0, 23, 59, 59);
    
    // Fetch appointments for current month
    const appointmentsRef = collection(db, 'appointments');
    const appointmentsQuery = query(
      appointmentsRef,
      where('date', '>=', Timestamp.fromDate(startOfMonth)),
      where('date', '<=', Timestamp.fromDate(endOfMonth)),
      orderBy('date', 'asc')
    );
    
    const appointmentsSnapshot = await getDocs(appointmentsQuery);
    const appointmentsData = [];
    const petIds = new Set();
    const userIds = new Set();
    
    appointmentsSnapshot.forEach((doc) => {
      const data = doc.data();
      appointmentsData.push({
        id: doc.id,
        ...data,
        date: data.date instanceof Timestamp ? data.date.toDate() : data.date
      });
      
      // Collect pet IDs and user IDs for fetching related data
      if (data.petIds && data.petIds.length > 0) {
        data.petIds.forEach(petId => petIds.add(petId));
      }
      if (data.userId) {
        userIds.add(data.userId);
      }
    });
    
    // Fetch pets data with owner information
    let petsData = [];
    if (petIds.size > 0) {
      const petsRef = collection(db, 'pets');
      const petsQuery = query(petsRef, where('__name__', 'in', Array.from(petIds)));
      const petsSnapshot = await getDocs(petsQuery);
      
      petsSnapshot.forEach((doc) => {
        const data = doc.data();
        petsData.push({
          id: doc.id,
          name: data.name,
          species: data.species,
          ownerId: data.ownerId,
          ageYears: data.ageYears,
          ageMonths: data.ageMonths,
          ageWeeks: data.ageWeeks,
          weight: data.weight,
          status: data.status
        });
      });
      
      // Fetch owner information for all unique user IDs
      const ownerIds = [...new Set(petsData.map(pet => pet.ownerId).filter(Boolean))];
      let ownersData = [];
      if (ownerIds.length > 0) {
        const usersRef = collection(db, 'users');
        const batchSize = 10; // Firestore 'in' query limit
        
        for (let i = 0; i < ownerIds.length; i += batchSize) {
          const batch = ownerIds.slice(i, i + batchSize);
          const ownersQuery = query(usersRef, where('__name__', 'in', batch));
          const ownersSnapshot = await getDocs(ownersQuery);
          
          ownersSnapshot.forEach((doc) => {
            const data = doc.data();
            ownersData.push({
              userId: doc.id,
              firstName: data.firstName,
              lastName: data.lastName,
              email: data.email,
              phone: data.phone,
              role: data.role,
              status: data.status
            });
          });
        }
      }
      
      // Map owner data to pets
      petsData.forEach(pet => {
        if (!pet.ownerId) {
          pet.ownerName = 'Unknown Owner';
          pet.ownerPhone = '';
          pet.ownerEmail = '';
          return;
        }
        
        const owner = ownersData.find(owner => owner.userId === pet.ownerId);
        if (owner) {
          pet.ownerName = `${owner.firstName || ''} ${owner.lastName || ''}`.trim() || 'Unknown Owner';
          pet.ownerPhone = owner.phone || '';
          pet.ownerEmail = owner.email || '';
        } else {
          pet.ownerName = 'Unknown Owner';
          pet.ownerPhone = '';
          pet.ownerEmail = '';
        }
      });
    }
    
    // Also fetch owner data for appointments that have userId but no pet data
    let allOwnersData = [];
    if (userIds.size > 0) {
      const usersRef = collection(db, 'users');
      const batchSize = 10;
      const userIdsArray = Array.from(userIds);
      
      for (let i = 0; i < userIdsArray.length; i += batchSize) {
        const batch = userIdsArray.slice(i, i + batchSize);
        const ownersQuery = query(usersRef, where('__name__', 'in', batch));
        const ownersSnapshot = await getDocs(ownersQuery);
        
        ownersSnapshot.forEach((doc) => {
          const data = doc.data();
          allOwnersData.push({
            userId: doc.id,
            firstName: data.firstName,
            lastName: data.lastName,
            email: data.email,
            phone: data.phone,
            role: data.role,
            status: data.status
          });
        });
      }
    }
    
    // Transform appointments with proper owner information
    appointments.value = appointmentsData.map(apt => {
      const petData = petsData.find(pet => pet.id === apt.petIds?.[0]);
      
      // Get owner information
      let ownerName = 'Unknown Owner';
      let ownerPhone = '';
      let ownerEmail = '';
      
      if (petData) {
        ownerName = petData.ownerName || 'Unknown Owner';
        ownerPhone = petData.ownerPhone || '';
        ownerEmail = petData.ownerEmail || '';
      } else if (apt.ownerName) {
        // Fallback to appointment owner data if available
        ownerName = apt.ownerName;
        ownerPhone = apt.ownerPhone || '';
        ownerEmail = apt.ownerEmail || '';
      } else if (apt.userId) {
        // Try to find owner data from the directly fetched user data
        const directOwner = allOwnersData.find(owner => owner.userId === apt.userId);
        if (directOwner) {
          ownerName = `${directOwner.firstName || ''} ${directOwner.lastName || ''}`.trim() || 'Unknown Owner';
          ownerPhone = directOwner.phone || '';
          ownerEmail = directOwner.email || '';
        }
      }
      
      // Handle Firebase Timestamp objects for date
      let appointmentDate;
      if (apt.date && typeof apt.date.toDate === 'function') {
        appointmentDate = apt.date.toDate();
      } else if (apt.date instanceof Date) {
        appointmentDate = apt.date;
      } else {
        appointmentDate = new Date(apt.date);
      }
      
      // Extract time from the time string
      let timeSlot = '09:00';
      if (apt.time) {
        const timeParts = apt.time.split('-');
        if (timeParts.length > 0) {
          const startTimeStr = timeParts[0].trim();
          const timeMatch = startTimeStr.match(/(\d{1,2}):(\d{2})\s*(AM|PM)/i);
          if (timeMatch) {
            let hours = parseInt(timeMatch[1]);
            const minutes = timeMatch[2];
            const period = timeMatch[3].toUpperCase();
            
            if (period === 'PM' && hours !== 12) {
              hours += 12;
            } else if (period === 'AM' && hours === 12) {
              hours = 0;
            }
            
            timeSlot = `${hours.toString().padStart(2, '0')}:${minutes}`;
          }
        }
      }
      
      // Determine appointment type
      const isOnline = apt.serviceNames && 
        apt.serviceNames.some(service => 
          service.toLowerCase().includes('video') || 
          service.toLowerCase().includes('telehealth')
        );
      
      // Determine if appointment is expired, current, or future
      const now = new Date();
      let isExpired = false;
      let isCurrent = false;
      
      if (apt.time) {
        const timeParts = apt.time.split('-');
        if (timeParts.length > 1) {
          const endTimeStr = timeParts[1].trim();
          const timeMatch = endTimeStr.match(/(\d{1,2}):(\d{2})\s*(AM|PM)/i);
          if (timeMatch) {
            let endHours = parseInt(timeMatch[1]);
            const endMinutes = timeMatch[2];
            const period = timeMatch[3].toUpperCase();
            
            if (period === 'PM' && endHours !== 12) {
              endHours += 12;
            } else if (period === 'AM' && endHours === 12) {
              endHours = 0;
            }
            
            const appointmentEndTime = new Date(appointmentDate);
            appointmentEndTime.setHours(endHours, endMinutes, 0, 0);
            
            if (now > appointmentEndTime) {
              isExpired = true;
            } else if (now >= appointmentDate && now <= appointmentEndTime) {
              isCurrent = true;
            }
          }
        }
      }
      
      return {
        id: apt.id,
        petName: petData?.name || apt.petNames?.[0] || 'Unknown Pet',
        petType: petData?.species || apt.petSpeciesArray?.[0] || 'Unknown',
        ownerName: ownerName,
        ownerPhone: ownerPhone,
        ownerEmail: ownerEmail,
        type: isOnline ? 'Online' : 'Walk-in',
        date: appointmentDate,
        time: timeSlot,
        originalTime: apt.time,
        duration: apt.duration || 30,
        status: apt.status || 'pending',
        notes: apt.notes || '',
        videoLink: apt.videoLink || '',
        doctorName: apt.doctorName || 'Unassigned',
        doctorId: apt.doctorId || '',
        userId: apt.userId || '',
        serviceNames: apt.serviceNames || [],
        isExpired,
        isCurrent
      };
    });
    
  } catch (error) {
    console.error('Error fetching appointments:', error);
    appointments.value = [];
  } finally {
    loading.value = false;
  }
};

const filteredAppointments = computed(() => {
  let filtered = appointments.value;
  
  // Filter by expired status
  if (!showExpired.value) {
    filtered = filtered.filter(appt => !appt.isExpired);
  }
  
  return filtered;
});



const getAppointmentClass = (type) => {
const classes = {
  'Online': 'bg-blue-100/80 text-blue-900 border border-blue-200',
  'Walk-in': 'bg-purple-100/80 text-purple-900 border border-purple-200',
  'Emergency': 'bg-green-100/80 text-green-900 border border-green-200'
};
return classes[type] || 'bg-gray-100/80 text-gray-900 border border-gray-200';
};

const getAppointmentStatusClass = (status) => {
  return {
    'confirmed': 'bg-green-400',
    'pending': 'bg-yellow-400',
    'approved': 'bg-green-400',
    'cancelled': 'bg-red-400',
    'completed': 'bg-purple-400',
    'ended': 'bg-gray-400'
  }[status] || 'bg-gray-400';
};

const formatTime = (timeString) => {
  if (!timeString) return '';
  return timeString;
};



// Navigate to approved appointments page when appointment is clicked
const openAppointmentDetails = (appointment) => {
  // Navigate to the approved appointments page
  router.push('/admin/appointments/approvedappointments');
};









// Fetch appointments on component mount
onMounted(async () => {
  await fetchAppointments();
});

// Remove the watch to prevent multiple fetches
// The appointments will be fetched once on mount and can be refreshed manually
</script>

<style scoped>
/* Custom scrollbar styles */
.overflow-y-auto {
  scrollbar-width: thin;
  scrollbar-color: rgba(0,0,0,0.2) transparent;
}

.overflow-y-auto::-webkit-scrollbar {
  width: 6px;
}

.overflow-y-auto::-webkit-scrollbar-track {
  background: transparent;
}

.overflow-y-auto::-webkit-scrollbar-thumb {
  background-color: rgba(0,0,0,0.2);
  border-radius: 3px;
}
</style>