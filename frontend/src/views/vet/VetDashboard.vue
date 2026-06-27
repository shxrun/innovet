<template>
  <div class="p-3 sm:p-4 md:p-6 bg-white rounded-2xl">
    <!-- Header Section -->
    <div class="mb-6 sm:mb-8">
      <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between mb-4 sm:mb-6 gap-4">
        <div>
          <h1 class="text-xl sm:text-2xl font-semibold text-gray-900">Veterinary Dashboard</h1>
          <p class="text-sm sm:text-base text-gray-500 mt-1">Monitor your veterinary practice performance</p>
        </div>
        
        <!-- Time Period Filter -->
        <!-- Mobile Dropdown -->
        <div class="block sm:hidden ml-auto relative mobile-dropdown-container">
          <button
            @click="showMobileDropdown = !showMobileDropdown"
            class="px-3 py-2 pr-3 text-sm border border-gray-200 rounded-full focus:outline-none bg-white min-w-[140px] cursor-pointer flex items-center justify-between"
          >
            <span>{{ periodOptions.find(p => p.value === selectedPeriod)?.label }}</span>
            <svg class="w-4 h-4 text-gray-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
            </svg>
          </button>
          
          <!-- Custom dropdown menu -->
          <div v-if="showMobileDropdown" class="absolute top-full left-0 right-0 mt-1 bg-white border border-gray-200 rounded-lg shadow-lg z-50">
            <button
              v-for="period in periodOptions"
              :key="period.value"
              @click="selectedPeriod = period.value; updateVetDashboard(); showMobileDropdown = false"
              :class="[
                'w-full px-3 py-2 text-sm text-left hover:bg-gray-50 transition-colors',
                selectedPeriod === period.value ? 'bg-blue-50 text-blue-600' : 'text-gray-700',
                period === periodOptions[0] ? 'rounded-t-lg' : '',
                period === periodOptions[periodOptions.length - 1] ? 'rounded-b-lg' : ''
              ]"
            >
              {{ period.label }}
            </button>
          </div>
        </div>
        
        <!-- Desktop Tabs -->
        <div class="hidden sm:flex items-center bg-white border-b border-gray-200">
          <button
            v-for="period in periodOptions"
            :key="period.value"
            @click="selectedPeriod = period.value; updateVetDashboard()"
            :class="[
              'px-4 md:px-6 py-3 text-sm font-medium transition-all duration-200 whitespace-nowrap relative',
              selectedPeriod === period.value
                ? 'text-blue-600 border-t-2 border-blue-600 bg-gradient-to-b from-blue-100 to-blue-50/30'
                : 'text-gray-600 hover:text-gray-900 hover:bg-gray-50'
            ]"
          >
            {{ period.label }}
          </button>
        </div>
      </div>
    </div>

    <!-- Top Row: Statistics Cards -->
    <div class="grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 mb-6 sm:mb-8">
      <div v-for="(stat, index) in filteredStats" :key="stat.title" 
           class="bg-white rounded-lg border border-gray-200 p-3 sm:p-4 lg:p-6 hover:shadow-md transition-shadow duration-200">
        <div class="flex flex-col">
          <!-- Top section with title and icon -->
          <div class="flex justify-between items-start mb-3 gap-2">
            <p class="text-xs sm:text-sm lg:text-base font-medium text-gray-500 flex-1 leading-tight">{{ stat.title }}</p>
            <div :class="`bg-${stat.color}-100 p-2 rounded-lg flex-shrink-0`">
              <component :is="stat.icon" class="w-4 h-4 sm:w-5 sm:h-5 lg:w-6 lg:h-6" :class="`text-${stat.color}-600`" />
            </div>
          </div>
          
          <!-- Fixed height center section for consistent number positioning -->
          <div class="h-8 sm:h-10 lg:h-12 flex items-center justify-center mb-3">
            <h3 class="text-sm sm:text-lg lg:text-3xl font-bold text-gray-900 leading-none text-center min-w-[2ch]">
              <span v-if="statsLoading" class="animate-pulse bg-gray-200 h-3 sm:h-5 lg:h-8 w-6 sm:w-10 lg:w-16 rounded"></span>
              <span v-else>{{ stat.value }}</span>
            </h3>
          </div>
          
          <!-- Bottom section with percentage -->
          <div class="flex items-center justify-center gap-1">
            <span v-if="statsLoading" class="animate-pulse bg-gray-200 h-2 w-12 rounded"></span>
            <template v-else>
              <component :is="stat.trend === 'up' ? ArrowUp : ArrowDown" 
                              :class="`w-2 h-2 sm:w-3 sm:h-3 ${stat.trend === 'up' ? 'text-green-500' : 'text-red-500'}`" />
              <span :class="`${stat.trend === 'up' ? 'text-green-600' : 'text-red-600'} text-[10px] sm:text-xs font-medium`">
                {{ stat.percentage }}
              </span>
              <span class="text-gray-500 text-[10px] sm:text-xs ml-1">{{ getComparisonLabel() }}</span>
            </template>
          </div>
        </div>
      </div>
    </div>

    <!-- Charts Section -->
    <div class="grid grid-cols-1 lg:grid-cols-4 gap-4 sm:gap-6 mb-6 sm:mb-8">
      <!-- Appointments Overview (Larger) -->
      <div class="lg:col-span-2 bg-white rounded-lg border border-gray-200">
        <div class="p-4 sm:p-6 border-b border-gray-200">
          <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-3">
          <div>
              <h3 class="text-lg sm:text-xl font-bold text-gray-900 mb-2">Appointments Overview</h3>
              <div class="flex items-center gap-4">
              <div class="flex items-center gap-2">
                  <div class="w-3 h-3 rounded-full bg-blue-500"></div>
                  <span class="text-xs sm:text-sm text-gray-600">Total Appointments</span>
                </div>
              </div>
            </div>
            <div class="text-left sm:text-right">
              <div class="flex items-center gap-2 mb-1">
                <span class="text-xs sm:text-sm text-gray-500">Period</span>
                <span class="text-xs sm:text-sm font-semibold text-gray-700">{{ getPeriodLabel() }}</span>
              </div>
              <div class="flex items-center gap-2">
                <span class="text-xs sm:text-sm text-gray-500">Total</span>
                <span class="text-xs sm:text-sm font-semibold text-gray-700">{{ filteredAppointments.reduce((sum, count) => sum + count, 0) }} appointments</span>
              </div>
            </div>
          </div>
        </div>

        <div class="p-4 sm:p-6">
          <div class="h-[250px] sm:h-[300px] md:h-[400px] relative">
            <div v-if="loading" class="w-full h-full flex items-center justify-center">
              <div class="animate-pulse bg-gray-200 w-full h-full rounded-lg"></div>
            </div>
            <canvas v-else ref="appointmentsChart" class="w-full h-full"></canvas>
          </div>
        </div>
      </div>

      <!-- Today's Appointments -->
      <div class="bg-white rounded-lg border border-gray-200">
        <div class="p-4 sm:p-6 border-b border-gray-200">
          <div class="flex items-center justify-between">
            <h3 class="text-sm sm:text-xl font-bold text-gray-900">Today's Schedule</h3>
            <button 
              @click="startQueue"
              :disabled="filteredTodaysAppointments.length === 0"
              class="bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed text-white px-2 sm:px-3 py-1.5 rounded-full text-xs font-medium transition-colors flex items-center gap-1.5 w-auto justify-center"
            >
              <svg class="w-3 h-3 sm:w-4 sm:h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
              </svg>
              View Queue
              <span v-if="filteredTodaysAppointments.length > 0" class="bg-white/20 px-2 py-1 rounded-full text-xs">
                {{ filteredTodaysAppointments.length }}
              </span>
            </button>
          </div>
        </div>
        <div class="p-3 sm:p-4 lg:p-6">
          <div v-if="loading" class="space-y-3 sm:space-y-4">
            <div v-for="i in 3" :key="i" class="flex items-center justify-between p-3 sm:p-4 bg-gray-50 rounded-lg">
              <div class="flex items-center gap-3">
                <div class="animate-pulse bg-gray-200 h-4 w-4 rounded-full"></div>
                <div class="animate-pulse bg-gray-200 h-4 w-4 rounded"></div>
                <div class="flex-1">
                  <div class="animate-pulse bg-gray-200 h-4 w-20 rounded mb-1"></div>
                  <div class="animate-pulse bg-gray-200 h-3 w-32 rounded"></div>
                </div>
              </div>
              <div class="animate-pulse bg-gray-200 h-4 w-16 rounded"></div>
            </div>
          </div>
          <div v-else-if="filteredTodaysAppointments.length === 0" class="text-center py-8">
            <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
              </svg>
            </div>
            <p class="text-gray-500 font-medium">No appointments today</p>
            <p class="text-sm text-gray-400 mt-1">Enjoy a quiet day!</p>
          </div>
          <div v-else class="space-y-3 sm:space-y-4">
            <div v-for="appointment in filteredTodaysAppointments.slice(0, 3)" :key="appointment.id" 
                 :class="[
                   'group p-3 sm:p-4 rounded-lg transition-all duration-300 border',
                   appointment.timeStatus === 'past' 
                     ? 'bg-gray-50 border-gray-200 opacity-60' 
                     : appointment.timeStatus === 'current'
                     ? 'bg-green-50 border-green-200 shadow-md'
                     : 'bg-blue-50 hover:bg-blue-100 border-blue-200 hover:border-blue-300 shadow-sm hover:shadow-md'
                 ]">
              <div class="flex items-center justify-between mb-2 sm:mb-3">
            <div class="flex items-center gap-2 sm:gap-3">
              <div class="flex items-center gap-1 sm:gap-2">
                <div class="w-1.5 h-1.5 sm:w-2 sm:h-2 rounded-full" 
                         :class="appointment.timeStatus === 'past' ? 'bg-gray-400' : 
                                appointment.timeStatus === 'current' ? 'bg-green-500 animate-pulse' : 
                                appointment.status === 'completed' ? 'bg-green-500' : 'bg-blue-500'">
                </div>
                <component 
                  :is="appointment.petType === 'Cat' ? Cat : PawPrint" 
                      :class="[
                        'w-3 h-3 sm:w-4 sm:h-4',
                        appointment.timeStatus === 'past' ? 'text-gray-400' : 'text-gray-500'
                      ]"
                />
              </div>
              <div>
                    <p :class="[
                      'text-xs sm:text-sm font-semibold',
                      appointment.timeStatus === 'past' ? 'text-gray-500' : 'text-gray-900'
                    ]">{{ appointment.time }}</p>
                    <p :class="[
                      'text-[10px] sm:text-xs',
                      appointment.timeStatus === 'past' ? 'text-gray-400' : 'text-gray-600'
                    ]">{{ appointment.petName }} - {{ appointment.service }}</p>
                    <p :class="[
                      'text-[10px] sm:text-xs',
                      appointment.timeStatus === 'past' ? 'text-gray-400' : 'text-gray-500'
                    ]">{{ appointment.doctorName }}</p>
                  </div>
                </div>
                <div class="flex flex-col items-end gap-0.5 sm:gap-1">
                  <span class="text-[10px] sm:text-xs font-medium px-1.5 sm:px-2 py-0.5 sm:py-1 rounded-full" 
                        :class="appointment.timeStatus === 'past' ? 'bg-gray-100 text-gray-500' :
                               appointment.timeStatus === 'current' ? 'bg-green-100 text-green-700' :
                               appointment.status === 'completed' ? 'bg-green-100 text-green-700' : 'bg-blue-100 text-blue-700'">
                    {{ appointment.status }}
                  </span>
                  <span v-if="appointment.timeStatus === 'past'" class="text-[10px] sm:text-xs text-gray-400">
                    Completed
                  </span>
                  <span v-else-if="appointment.timeStatus === 'current'" class="text-[10px] sm:text-xs text-green-600 font-medium">
                    In Progress
                  </span>
                </div>
              </div>
            </div>
            <div v-if="filteredTodaysAppointments.length > 3" class="text-center pt-2">
              <p class="text-sm text-gray-500">+{{ filteredTodaysAppointments.length - 3 }} more appointments</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Pet Categories Donut Chart -->
      <div class="bg-white rounded-lg border border-gray-200">
        <div class="p-4 sm:p-6 border-b border-gray-200">
          <h3 class="text-lg sm:text-xl font-bold text-gray-900">Pet Distribution</h3>
        </div>
        <div class="p-4 sm:p-6">
          <div v-if="loading" class="flex items-center justify-center">
            <div class="relative w-32 h-32 sm:w-40 sm:h-40 md:w-48 md:h-48">
              <div class="animate-pulse bg-gray-200 w-full h-full rounded-full"></div>
              <div class="absolute inset-0 flex flex-col items-center justify-center">
                <div class="animate-pulse bg-gray-200 h-6 sm:h-8 w-12 sm:w-16 rounded mb-2"></div>
                <div class="animate-pulse bg-gray-200 h-3 sm:h-4 w-16 sm:w-20 rounded"></div>
              </div>
            </div>
          </div>
          <div v-else class="flex items-center justify-center">
          <div class="relative w-32 h-32 sm:w-40 sm:h-40 md:w-48 md:h-48">
              <canvas ref="petDistributionChart" class="w-full h-full"></canvas>
            <div class="absolute inset-0 flex flex-col items-center justify-center">
                <span class="text-xl sm:text-2xl md:text-3xl font-bold text-gray-900">{{ totalPets }}</span>
                <span class="flex items-center text-xs sm:text-sm text-green-500 mt-1">
                <svg 
                  class="w-3 h-3 mr-1" 
                  viewBox="0 0 24 24" 
                  fill="none" 
                  stroke="currentColor" 
                  stroke-width="2"
                >
                  <path d="M7 13l5-5 5 5" />
                </svg>
                  {{ totalPets > 0 ? '100%' : '0%' }}
              </span>
              </div>
            </div>
          </div>
          <div v-if="loading" class="space-y-3 mt-6">
            <div v-for="i in 4" :key="i" class="flex items-center justify-between py-2">
              <div class="flex items-center gap-2">
                <div class="animate-pulse bg-gray-200 w-3 h-3 rounded-full"></div>
                <div class="animate-pulse bg-gray-200 h-4 w-16 rounded"></div>
        </div>
            <div class="flex items-center gap-2">
                <div class="animate-pulse bg-gray-200 h-4 w-8 rounded"></div>
                <div class="animate-pulse bg-gray-200 h-4 w-12 rounded"></div>
              </div>
            </div>
          </div>
          <div v-else-if="filteredSegments.length === 0" class="text-center py-8">
            <div class="w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-3">
              <svg class="w-6 h-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"></path>
              </svg>
            </div>
            <p class="text-gray-500">No pet data available</p>
          </div>
          <div v-else class="space-y-3 mt-6">
            <div v-for="segment in filteredSegments" :key="segment.label" 
                 class="flex items-center justify-between py-2 hover:bg-gray-50 rounded-lg px-2 transition-colors duration-200">
              <div class="flex items-center gap-3">
                <div :style="{ backgroundColor: segment.color }" class="w-3 h-3 rounded-full shadow-sm"></div>
                <span class="text-sm font-medium text-gray-700">{{ segment.label }}</span>
            </div>
            <div class="flex items-center gap-2">
                <span class="text-sm font-semibold text-gray-900">{{ segment.value }}</span>
                <span class="text-sm text-gray-500">({{ segment.percentage }}%)</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Telehealth Sessions -->
    <div class="bg-white rounded-lg border border-gray-200 mb-6 sm:mb-8">
      <div class="p-4 sm:p-6 border-b border-gray-200">
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
          <div>
            <h3 class="text-lg sm:text-xl font-bold text-gray-900 mb-1">Telehealth Sessions</h3>
            <p class="text-xs sm:text-sm text-gray-600">Today's online consultations</p>
          </div>
          <div class="flex items-center gap-2">
            <div class="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
            <span class="text-xs font-medium text-green-600">Live</span>
          </div>
        </div>
      </div>
      <div class="p-3 sm:p-4 lg:p-6">
        <div v-if="loading" class="space-y-3 sm:space-y-4">
          <div v-for="i in 3" :key="i" class="animate-pulse">
            <div class="flex items-center justify-between p-3 sm:p-4 bg-gray-50 rounded-lg">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 bg-gray-200 rounded-full"></div>
                <div class="flex-1">
                  <div class="h-4 bg-gray-200 rounded w-24 mb-2"></div>
                  <div class="h-3 bg-gray-200 rounded w-32"></div>
                </div>
              </div>
              <div class="text-right">
                <div class="h-3 bg-gray-200 rounded w-16 mb-1"></div>
                <div class="h-4 bg-gray-200 rounded w-20"></div>
              </div>
            </div>
          </div>
        </div>
        <div v-else-if="telehealthSessions.length === 0" class="text-center py-8 sm:py-12">
          <div class="w-16 h-16 sm:w-20 sm:h-20 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4 sm:mb-6">
            <Video class="w-8 h-8 sm:w-10 sm:h-10 text-gray-400" />
          </div>
          <h3 class="text-base sm:text-lg font-semibold text-gray-700 mb-1 sm:mb-2">No Telehealth Sessions</h3>
          <p class="text-xs sm:text-sm text-gray-500 mb-3 sm:mb-4">No online consultations scheduled for today</p>
          <div class="w-12 sm:w-16 h-1 bg-gray-300 mx-auto"></div>
        </div>
        <div v-else class="space-y-3 sm:space-y-4">
          <div v-for="session in telehealthSessions" :key="session.id" 
               class="group p-3 sm:p-4 bg-white rounded-lg border border-gray-200 hover:border-gray-300 hover:shadow-lg transition-all duration-300">
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-3 sm:gap-4">
                <div class="w-10 h-10 sm:w-12 sm:h-12 bg-blue-500 rounded-full flex items-center justify-center">
                  <Video class="w-5 h-5 sm:w-6 sm:h-6 text-white" />
                </div>
                <div>
                  <p class="text-xs sm:text-sm font-semibold text-gray-900">{{ session.petName }}</p>
                  <div class="flex items-center gap-1 mt-1">
                    <User class="w-3 h-3 text-gray-400" />
                    <p class="text-xs text-gray-500">{{ session.ownerName }}</p>
                  </div>
                </div>
              </div>
              <div class="text-right">
                <p class="text-xs text-gray-600">{{ session.date }}, {{ session.time }}</p>
                <span :class="`text-xs font-bold px-2 py-1 rounded-full mt-1 inline-block ${session.status === 'In Progress' ? 'bg-green-100 text-green-700' : 'bg-blue-100 text-blue-700'}`">
                  {{ session.status }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Recent Activity -->
    <div class="bg-white rounded-lg border border-gray-200">
      <div class="p-4 sm:p-6 border-b border-gray-200">
        <div class="flex items-center justify-between">
          <div>
            <h2 class="text-lg sm:text-xl font-bold text-gray-900 mb-1">Recent Activity</h2>
            <p class="text-xs sm:text-sm text-gray-600">Latest updates and notifications</p>
          </div>
          <div class="flex items-center gap-2">
            <div class="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
            <span class="text-xs font-medium text-green-600">Live Updates</span>
          </div>
        </div>
      </div>
      <div class="p-3 sm:p-4 lg:p-6">
        <div v-if="loading" class="space-y-4 sm:space-y-6">
          <div v-for="i in 4" :key="i" class="animate-pulse">
            <div class="flex items-start gap-3 sm:gap-4">
              <div class="w-8 h-8 sm:w-12 sm:h-12 bg-gray-200 rounded-full"></div>
              <div class="flex-1 space-y-1 sm:space-y-2">
                <div class="h-3 sm:h-4 bg-gray-200 rounded w-3/4"></div>
                <div class="h-2 sm:h-3 bg-gray-200 rounded w-1/2"></div>
                <div class="h-2 sm:h-3 bg-gray-200 rounded w-1/4"></div>
              </div>
            </div>
          </div>
        </div>
        <div v-else-if="filteredRecentActivities.length === 0" class="text-center py-8 sm:py-12">
          <div class="w-16 h-16 sm:w-20 sm:h-20 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4 sm:mb-6">
            <svg class="w-8 h-8 sm:w-10 sm:h-10 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
          </div>
          <h3 class="text-base sm:text-lg font-semibold text-gray-700 mb-1 sm:mb-2">No Recent Activities</h3>
          <p class="text-xs sm:text-sm text-gray-500 mb-3 sm:mb-4">When new appointments or updates occur, they'll appear here</p>
          <div class="w-12 sm:w-16 h-1 bg-gray-300 mx-auto"></div>
        </div>
        <div v-else class="space-y-3 sm:space-y-4">
          <div v-for="(activity, index) in filteredRecentActivities" :key="index" 
               class="group relative">
            <!-- Activity Item -->
            <div class="flex items-start gap-2 sm:gap-3 lg:gap-4 p-3 sm:p-4 lg:p-5 bg-white rounded-xl border border-gray-200 hover:border-gray-300 hover:shadow-lg transition-all duration-300">
              <!-- Activity Icon -->
              <div class="flex-shrink-0">
                <div :class="`w-8 h-8 sm:w-10 sm:h-10 lg:w-12 lg:h-12 rounded-full ${activity.bgColor} flex items-center justify-center shadow-sm`">
                  <component :is="activity.icon" class="w-4 h-4 sm:w-5 sm:h-5 lg:w-6 lg:h-6" :class="activity.iconColor" />
                </div>
              </div>
              
              <!-- Activity Content -->
              <div class="flex-1 min-w-0">
                <div class="flex flex-col sm:flex-row sm:items-start sm:justify-between mb-1 sm:mb-2 lg:mb-3 gap-1 sm:gap-2">
                  <div class="flex-1">
                    <h3 class="text-[10px] sm:text-xs lg:text-sm font-semibold text-gray-900 mb-0.5 sm:mb-1">{{ activity.title }}</h3>
                    <p class="text-[9px] sm:text-[10px] lg:text-xs text-gray-600 leading-tight">{{ activity.description }}</p>
                  </div>
                  <div class="flex items-center gap-1 sm:gap-2 sm:ml-4">
                    <span class="text-[9px] sm:text-[10px] lg:text-xs font-medium text-gray-500 bg-gray-100 px-1.5 sm:px-2 lg:px-3 py-0.5 sm:py-1 rounded-full">
                      {{ activity.time }}
                    </span>
                  </div>
                </div>
                
                <!-- Status Badge -->
                <div class="flex items-center gap-1 sm:gap-2">
                  <div class="flex items-center gap-1 sm:gap-2">
                    <div class="w-1.5 h-1.5 sm:w-2 sm:h-2 rounded-full" 
                         :class="activity.status === 'completed' ? 'bg-green-500' : 
                                activity.status === 'approved' ? 'bg-blue-500' : 
                                activity.status === 'pending' ? 'bg-yellow-500' : 'bg-red-500'">
                    </div>
                    <span class="text-[9px] sm:text-[10px] lg:text-xs font-semibold capitalize px-2 sm:px-3 py-0.5 sm:py-1 rounded-full" 
                          :class="activity.status === 'completed' ? 'bg-green-100 text-green-700' : 
                                 activity.status === 'approved' ? 'bg-blue-100 text-blue-700' : 
                                 activity.status === 'pending' ? 'bg-yellow-100 text-yellow-700' : 'bg-red-100 text-red-700'">
                      {{ activity.status }}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
          
            <!-- View All Activities Button -->
            <div class="text-center pt-4">
              <button @click="viewAllActivities" class="inline-flex items-center gap-2 text-sm font-medium text-blue-600 hover:text-blue-700 transition-colors duration-200 group">
                <span>View All Activities</span>
                <svg class="w-4 h-4 group-hover:translate-x-1 transition-transform duration-200" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                </svg>
              </button>
            </div>
        </div>
      </div>
    </div>
  </div>
</template>


<script setup>
import { ref, computed, onMounted, watch, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { 
  Calendar,
  ArrowUp,
  ArrowDown,
  CheckCircle,
  AlertCircle,
  Clock,
  PawPrint,
  Cat,
  User,
  Video,
  Users,
  VideoIcon,
  FootprintsIcon
} from 'lucide-vue-next'
import { useAppointmentStore } from '@/stores/modules/appointmentStore'
import { useAuthStore } from '@/stores/modules/authStore'
import vetDashboardStatsService from '@/services/vetDashboardStatsService'
import { Chart, registerables } from 'chart.js'

// Register Chart.js components
Chart.register(...registerables)

// Initialize stores
const appointmentStore = useAppointmentStore()
const authStore = useAuthStore()
const router = useRouter()

// References for chart canvases
const appointmentsChart = ref(null)
const petDistributionChart = ref(null)

// Chart instances
let lineChart = null
let doughnutChart = null

// Get current vet ID
const vetId = computed(() => authStore.currentUser?.userId)

// Loading states
const loading = ref(false)
const statsLoading = ref(false)

const selectedPeriod = ref('1')
const showMobileDropdown = ref(false)
const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']

const periodOptions = [
  { value: '1', label: 'Current Month' },
  { value: '3', label: 'Last 3 Months' },
  { value: '6', label: 'Last 6 Months' },
  { value: '12', label: 'Last 12 Months' }
]

// Get current month and year for chart labels
const currentDate = new Date()
const currentMonth = currentDate.getMonth()
const currentYear = currentDate.getFullYear()


// Dashboard data refs
const stats = ref([
  { title: 'Total Appointments', value: '0', icon: Calendar, color: 'blue', trend: 'up', percentage: '0%' },
  { title: 'Active Patients', value: '0', icon: Users, color: 'green', trend: 'up', percentage: '0%' },
  { title: 'Online Session', value: '0', icon: VideoIcon, color: 'purple', trend: 'up', percentage: '0%' },
  { title: 'Walk-in Session', value: '0', icon: FootprintsIcon, color: 'orange', trend: 'up', percentage: '0%' }
])

const todaysAppointments = ref([])
const segments = ref([])
const recentActivities = ref([])
const appointments = ref([])
const chartLabels = ref([])

// Fetch dashboard data
const fetchVetDashboardData = async () => {
  try {
    loading.value = true
    statsLoading.value = true
    
    if (!vetId.value) {
      console.error('No vet ID found')
      return
    }
    
    const periodMonths = parseInt(selectedPeriod.value)
    const dashboardStats = await vetDashboardStatsService.getVetDashboardStats(vetId.value, periodMonths)
    
    // Update stats
    stats.value = [
    { 
      title: 'Total Appointments', 
        value: dashboardStats.totalAppointments.toString(), 
      icon: Calendar,
      color: 'blue', 
        trend: dashboardStats.comparisonStats.totalAppointments.trend, 
        percentage: `${dashboardStats.comparisonStats.totalAppointments.change}%` 
    },
    { 
      title: 'Active Patients', 
        value: dashboardStats.approvedAppointments.toString(), 
      icon: Users,
      color: 'green', 
        trend: dashboardStats.comparisonStats.approvedAppointments.trend, 
        percentage: `${dashboardStats.comparisonStats.approvedAppointments.change}%` 
    },
    { 
      title: 'Online Session', 
        value: dashboardStats.onlineSessions.toString(), 
      icon: VideoIcon,
      color: 'purple', 
        trend: dashboardStats.comparisonStats.onlineSessions.trend, 
        percentage: `${dashboardStats.comparisonStats.onlineSessions.change}%` 
    },
    { 
      title: 'Walk-in Session', 
        value: dashboardStats.walkInSessions.toString(), 
      icon: FootprintsIcon,
      color: 'orange', 
        trend: dashboardStats.comparisonStats.walkInSessions.trend, 
        percentage: `${dashboardStats.comparisonStats.walkInSessions.change}%` 
      }
    ]
    
    // Update today's appointments
    todaysAppointments.value = dashboardStats.todayAppointments
    
    // Update pet distribution
    segments.value = dashboardStats.petDistribution
    
    // Update recent activities
    recentActivities.value = dashboardStats.recentActivities.map(activity => ({
      ...activity,
      icon: getActivityIcon(activity.status)
    }))
    
    // Update monthly trend data
    appointments.value = dashboardStats.monthlyTrend.map(item => item.count)
    
    // Update chart labels from service data
    chartLabels.value = dashboardStats.monthlyTrend.map(item => item.period)
    
  } catch (error) {
    console.error('Error fetching vet dashboard data:', error)
    // Set default values on error
    stats.value = [
      { title: 'Total Appointments', value: '0', icon: Calendar, color: 'blue', trend: 'up', percentage: '0%' },
      { title: 'Active Patients', value: '0', icon: Users, color: 'green', trend: 'up', percentage: '0%' },
      { title: 'Online Session', value: '0', icon: VideoIcon, color: 'purple', trend: 'up', percentage: '0%' },
      { title: 'Walk-in Session', value: '0', icon: FootprintsIcon, color: 'orange', trend: 'up', percentage: '0%' }
    ]
    todaysAppointments.value = []
    segments.value = []
    recentActivities.value = []
    appointments.value = Array.from({ length: 12 }, () => 0)
    chartLabels.value = []
  } finally {
    loading.value = false
    statsLoading.value = false
  }
}

const getActivityIcon = (status) => {
  switch (status) {
    case 'approved': return Calendar
    case 'completed': return CheckCircle
    case 'cancelled': return AlertCircle
    case 'pending': return Clock
    default: return Calendar
  }
}


// Computed properties
const filteredStats = computed(() => {
  return stats.value
})

const filteredAppointments = computed(() => {
  return appointments.value
})

const filteredTodaysAppointments = computed(() => {
  return todaysAppointments.value.filter(appointment => appointment.status === 'approved')
})

const filteredSegments = computed(() => {
  return segments.value
})

const filteredRecentActivities = computed(() => {
  return recentActivities.value
})

const totalPets = computed(() => filteredSegments.value.reduce((sum, segment) => sum + segment.value, 0))

const telehealthSessions = computed(() => {
  return todaysAppointments.value
    .filter(app => 
      app.status === 'approved' && 
      app.service?.toLowerCase().includes('video consultation')
    )
    .map(app => ({
      id: app.id,
      petName: app.petName || 'Unknown Pet',
      ownerName: app.ownerName || 'Unknown Owner',
      date: new Date().toISOString().split('T')[0],
      time: app.time || 'TBD',
      status: app.status || 'Scheduled'
    }))
})

// Helper functions
const getPeriodLabel = () => {
  const period = parseInt(selectedPeriod.value)
  return period === 1 ? 'Current Month' : `Last ${period} Months`
}

const getComparisonLabel = () => {
  const period = parseInt(selectedPeriod.value)
  if (period === 1) {
    return 'from last month'
  } else {
    return `from previous ${period} months`
  }
}

const getChartLabels = () => {
  const period = parseInt(selectedPeriod.value)
  const labels = []
  
  if (period === 1) {
    // For current month, show days from 1st to today
    const today = new Date()
    const currentMonth = today.getMonth()
    const currentYear = today.getFullYear()
    
    for (let day = 1; day <= today.getDate(); day++) {
      labels.push(`${day}/${currentMonth + 1}`)
    }
  } else if (period === 3) {
    // For 3 months, show last 12 weeks
    for (let i = 11; i >= 0; i--) {
      const date = new Date()
      date.setDate(date.getDate() - (i * 7))
      const monthName = months[date.getMonth()]
      const weekNumber = Math.ceil((date.getDate() + date.getDay()) / 7)
      labels.push(`${monthName} W${weekNumber}`)
    }
  } else {
    // For 6 and 12 months, show months
    for (let i = period - 1; i >= 0; i--) {
      const date = new Date()
      date.setMonth(date.getMonth() - i)
      labels.push(months[date.getMonth()])
    }
  }
  
  return labels
}





// Total appointments count
const totalAppointments = computed(() => {
  return filteredAppointments.value.reduce((sum, count) => sum + count, 0)
})

// Current month appointments count
const currentMonthAppointments = computed(() => {
  return filteredAppointments.value[filteredAppointments.value.length - 1] || 0
})



const generateNewData = () => {
  // No longer needed as we're using real data
}

const formatDate = (date, offset = 0) => {
  const d = new Date(date)
  d.setDate(d.getDate() + offset)
  return `${months[d.getMonth()]} ${d.getDate()}`
}

// Initialize and update the bar chart for appointments overview
const initBarChart = () => {
  if (!appointmentsChart.value) return
  
  const ctx = appointmentsChart.value.getContext('2d')
  
  // Destroy existing chart if it exists
  if (lineChart) lineChart.destroy()
  
  // Create modern gradient for bars
  const gradient = ctx.createLinearGradient(0, 0, 0, 400)
  gradient.addColorStop(0, 'rgba(59, 130, 246, 1)') // Blue-500
  gradient.addColorStop(0.7, 'rgba(59, 130, 246, 0.9)')
  gradient.addColorStop(1, 'rgba(147, 197, 253, 0.8)') // Blue-300
  
  lineChart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: chartLabels.value.length > 0 ? chartLabels.value : getChartLabels(),
      datasets: [{
        label: 'Total Appointments',
        data: filteredAppointments.value,
        backgroundColor: gradient,
        borderColor: 'rgba(59, 130, 246, 1)',
        borderWidth: 0,
        borderRadius: {
          topLeft: 8,
          topRight: 8,
          bottomLeft: 0,
          bottomRight: 0
        },
        borderSkipped: false,
        hoverBackgroundColor: 'rgba(37, 99, 235, 1)', // Blue-600
        hoverBorderColor: 'rgba(37, 99, 235, 1)',
        hoverBorderWidth: 0,
        hoverBorderRadius: {
          topLeft: 8,
          topRight: 8,
          bottomLeft: 0,
          bottomRight: 0
        }
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      interaction: {
        intersect: false,
        mode: 'index'
      },
      elements: {
        bar: {
          borderWidth: 0
        }
      },
      datasets: {
        bar: {
          barPercentage: 0.95,
          categoryPercentage: 0.95
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          grid: {
            color: 'rgba(148, 163, 184, 0.08)',
            drawBorder: false,
            lineWidth: 1
          },
          ticks: {
            stepSize: Math.max(1, Math.ceil(Math.max(...filteredAppointments.value) / 5)),
            color: 'rgba(71, 85, 105, 0.7)',
            font: {
              size: 11,
              weight: '600',
              family: 'Inter, system-ui, sans-serif'
            },
            padding: 12,
            callback: function(value) {
              return value
            }
          },
          border: {
            display: false
          }
        },
        x: {
          grid: {
            display: false
          },
          ticks: {
            color: 'rgba(71, 85, 105, 0.7)',
            font: {
              size: 11,
              weight: '600',
              family: 'Inter, system-ui, sans-serif'
            },
            padding: 8,
            maxRotation: 0,
            minRotation: 0
          },
          border: {
            display: false
          }
        }
      },
      plugins: {
        legend: {
          display: false
        },
        tooltip: {
          backgroundColor: 'rgba(255, 255, 255, 0.98)',
          titleColor: '#1e293b',
          bodyColor: '#475569',
          borderColor: 'rgba(59, 130, 246, 0.2)',
          borderWidth: 2,
          padding: 16,
          displayColors: false,
          cornerRadius: 12,
          titleFont: {
            size: 13,
            weight: '700',
            family: 'Inter, system-ui, sans-serif'
          },
          bodyFont: {
            size: 12,
            weight: '600',
            family: 'Inter, system-ui, sans-serif'
          },
          shadowOffsetX: 0,
          shadowOffsetY: 4,
          shadowBlur: 12,
          shadowColor: 'rgba(0, 0, 0, 0.1)',
          callbacks: {
            title: function(context) {
              return context[0].label
            },
            label: function(context) {
              return `${context.parsed.y} appointments`
            }
          }
        }
      }
    }
  })
}

// Initialize and update the doughnut chart for pet distribution
const initDoughnutChart = () => {
  if (!petDistributionChart.value) return
  
  const ctx = petDistributionChart.value.getContext('2d')
  
  // Destroy existing chart if it exists
  if (doughnutChart) doughnutChart.destroy()
  
  doughnutChart = new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: filteredSegments.value.map(segment => segment.label),
      datasets: [{
        data: filteredSegments.value.map(segment => segment.value),
        backgroundColor: filteredSegments.value.map(segment => segment.color),
        borderWidth: 0,
        hoverOffset: 8,
        borderRadius: 4
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      cutout: '70%',
      plugins: {
        legend: {
          display: false
        },
        tooltip: {
          backgroundColor: 'rgba(255, 255, 255, 0.95)',
          titleColor: '#1e293b',
          bodyColor: '#475569',
          borderColor: 'rgba(148, 163, 184, 0.2)',
          borderWidth: 1,
          padding: 12,
          cornerRadius: 8,
          callbacks: {
            label: function(context) {
              const value = context.parsed;
              const total = context.dataset.data.reduce((a, b) => a + b, 0);
              const percentage = Math.round((value / total) * 100);
              return `${context.label}: ${value} (${percentage}%)`;
            }
          }
        }
      }
    }
  })
}

const updateCharts = () => {
  initBarChart()
  initDoughnutChart()
}

// Watch for changes in filtered data to update charts
watch([filteredAppointments, filteredSegments], () => {
  updateCharts()
}, { deep: true })

const updateVetDashboard = async () => {
  await fetchVetDashboardData()
  updateCharts()
}

const startQueue = () => {
  // Redirect to VetQueue page
  router.push('/vet/queue')
}

const viewAllActivities = () => {
  // Redirect to Vet Appointment Approval page
  router.push('/vet/appointments/vetappointmentapproval')
}

onMounted(async () => {
  selectedPeriod.value = '1'
  
  // Fetch initial dashboard data
  await fetchVetDashboardData()
  
  // Initialize charts after the DOM has been updated
  nextTick(() => {
    updateCharts()
  })
  
  // Close mobile dropdown when clicking outside
  document.addEventListener('click', (e) => {
    if (!e.target.closest('.mobile-dropdown-container')) {
      showMobileDropdown.value = false
    }
  })
})
</script>
