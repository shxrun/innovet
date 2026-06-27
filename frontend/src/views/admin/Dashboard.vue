<template>
  <div class="p-3 sm:p-4 md:p-6 bg-white rounded-2xl">
    <!-- Header Section -->
    <div class="mb-6 sm:mb-8">
      <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between mb-4 sm:mb-6 gap-4">
        <div>
          <h1 class="text-xl sm:text-2xl font-semibold text-gray-900">Dashboard Overview</h1>
          <p class="text-sm sm:text-base text-gray-500 mt-1">Monitor your veterinary clinic's performance</p>
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
              @click="selectedPeriod = period.value; updateDashboard(); showMobileDropdown = false"
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
            @click="selectedPeriod = period.value; updateDashboard()"
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
            <h3 class="text-lg sm:text-xl font-bold text-gray-900">Today's Schedule</h3>
            <button 
              @click="toggleTodaySidebar"
              class="text-blue-600 hover:text-blue-700 text-xs sm:text-sm font-medium flex items-center gap-1"
            >
              <span>View All</span>
              <svg class="w-3 h-3 sm:w-4 sm:h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
              </svg>
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

    <!-- Bottom Row: Recent Activity -->
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

  <!-- Today's Appointments Sidebar -->
  <div 
    v-if="showTodaySidebar" 
    class="fixed inset-0 bg-black/50 z-50"
    @click="closeTodaySidebar"
  ></div>
  
  <div 
    :class="`fixed top-0 right-0 h-full w-full sm:w-[300px] lg:w-[350px] bg-white shadow-2xl transform transition-transform duration-500 ease-out z-50 flex flex-col ${
      showTodaySidebar ? 'translate-x-0' : 'translate-x-full'
    }`"
  >
    <div class="flex items-center justify-between p-3 sm:p-4 lg:p-6 border-b border-gray-200 flex-shrink-0">
      <div>
        <h2 class="text-sm sm:text-base lg:text-lg font-bold text-gray-900 mb-0.5 sm:mb-1">Today's Schedule</h2>
        <p class="text-[10px] sm:text-xs text-gray-600">Manage and view all appointments</p>
      </div>
      <button 
        @click="closeTodaySidebar"
        class="text-gray-500 hover:text-gray-700 hover:scale-110 transition-all duration-200 p-1 sm:p-1.5 lg:p-2 rounded-lg hover:bg-gray-100"
      >
        <svg class="w-4 h-4 sm:w-5 sm:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
        </svg>
      </button>
    </div>

    <!-- Filter Section -->
    <div class="p-3 sm:p-4 lg:p-6 border-b border-gray-200 bg-gray-50 flex-shrink-0">
      <div class="mb-2 sm:mb-3 lg:mb-4">
        <label class="block text-[10px] sm:text-xs font-semibold text-gray-700 mb-1 sm:mb-2">Filter by Veterinary</label>
        <div class="relative vet-dropdown-container">
          <button
            @click="showVetDropdown = !showVetDropdown"
            :disabled="loadingVets"
            class="w-full px-2 sm:px-3 py-1.5 sm:py-2 pr-3 text-xs sm:text-sm border border-gray-200 rounded-full focus:outline-none focus:ring-2 focus:ring-gray-200 disabled:bg-gray-100 disabled:cursor-not-allowed bg-white text-left flex items-center justify-between"
            style="border-radius: 9999px;"
          >
            <span>{{ selectedVetFilter ? availableVets.find(vet => vet.doctorId === selectedVetFilter)?.doctorName : 'All Veterinaries' }}</span>
            <svg class="w-3 h-3 sm:w-4 sm:h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
            </svg>
          </button>
          
          <!-- Custom dropdown menu -->
          <div v-if="showVetDropdown" class="absolute top-full left-0 right-0 mt-1 bg-white border border-gray-200 rounded-lg shadow-lg z-50 max-h-48 overflow-y-auto">
            <button
              @click="selectedVetFilter = ''; filterTodayAppointments(); showVetDropdown = false"
              class="w-full px-3 py-2 text-xs sm:text-sm text-left hover:bg-gray-50 transition-colors rounded-t-lg"
            >
              All Veterinaries
            </button>
            <button
              v-for="vet in availableVets"
              :key="vet.doctorId"
              @click="selectedVetFilter = vet.doctorId; filterTodayAppointments(); showVetDropdown = false"
              class="w-full px-3 py-2 text-xs sm:text-sm text-left hover:bg-gray-50 transition-colors"
              :class="vet === availableVets[availableVets.length - 1] ? 'rounded-b-lg' : ''"
            >
              {{ vet.doctorName }}
            </button>
          </div>
        </div>
      </div>
      
      <div class="flex items-center justify-between text-[10px] sm:text-xs text-gray-600">
        <span class="font-medium">Total: {{ filteredTodayAppointments.length }} appointments</span>
        <button 
          @click="clearVetFilter"
          v-if="selectedVetFilter"
          class="text-blue-600 hover:text-blue-700 font-medium text-[10px] sm:text-xs"
        >
          Clear Filter
        </button>
      </div>
    </div>

    <!-- Appointments List -->
    <div class="flex-1 overflow-y-auto">
      <div v-if="loading" class="p-3 sm:p-4 space-y-2 sm:space-y-3">
        <div v-for="i in 5" :key="i" class="animate-pulse">
          <div class="bg-gray-200 h-16 sm:h-20 rounded-lg"></div>
        </div>
      </div>
      
      <div v-else-if="filteredTodayAppointments.length === 0" class="p-3 sm:p-4 text-center">
        <div class="text-gray-400 mb-2 sm:mb-3">
          <svg class="w-10 h-10 sm:w-12 sm:h-12 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
          </svg>
        </div>
        <p class="text-xs sm:text-sm text-gray-500 font-medium">No appointments found</p>
        <p class="text-[10px] sm:text-xs text-gray-400 mt-1">
          {{ selectedVetFilter ? 'Try changing the filter or check back later' : 'No appointments scheduled for today' }}
        </p>
      </div>
      
      <div v-else class="p-3 sm:p-4 space-y-2 sm:space-y-3">
        <div 
          v-for="appointment in filteredTodayAppointments" 
          :key="appointment.id"
          :class="[
            'rounded-lg p-2 sm:p-3 border transition-all duration-300 group',
            appointment.timeStatus === 'past' 
              ? 'bg-gray-50 border-gray-200 opacity-70' 
              : appointment.timeStatus === 'current'
              ? 'bg-green-50 border-green-200 shadow-lg'
              : 'bg-blue-50 hover:bg-blue-100 border-blue-200 hover:border-blue-300 shadow-sm hover:shadow-lg'
          ]"
        >
          <!-- Header with Status and Time -->
          <div class="flex items-start justify-between mb-1.5 sm:mb-2">
            <div class="flex items-center gap-1 sm:gap-1.5">
              <div class="flex items-center gap-0.5 sm:gap-1">
                <div class="w-1.5 h-1.5 sm:w-2 sm:h-2 rounded-full" 
                     :class="appointment.timeStatus === 'past' ? 'bg-gray-400' : 
                            appointment.timeStatus === 'current' ? 'bg-green-500 animate-pulse' :
                            appointment.status === 'completed' ? 'bg-green-500' : 
                            appointment.status === 'approved' ? 'bg-blue-500' : 
                            appointment.status === 'pending' ? 'bg-yellow-500' : 'bg-red-500'">
                </div>
                <component 
                  :is="appointment.petType === 'Cat' ? Cat : PawPrint" 
                  :class="[
                    'w-3 h-3 sm:w-4 sm:h-4 group-hover:scale-110 transition-transform duration-200',
                    appointment.timeStatus === 'past' ? 'text-gray-400' : 'text-gray-500'
                  ]"
                />
              </div>
              <div>
                <p :class="[
                  'text-xs sm:text-sm font-bold',
                  appointment.timeStatus === 'past' ? 'text-gray-500' : 'text-gray-900'
                ]">{{ appointment.time }}</p>
                <p :class="[
                  'text-[10px] sm:text-xs',
                  appointment.timeStatus === 'past' ? 'text-gray-400' : 'text-gray-600'
                ]">{{ appointment.service }}</p>
              </div>
            </div>
            <div class="flex flex-col items-end gap-0.5">
              <span class="text-[9px] sm:text-[10px] font-medium px-1.5 sm:px-2 py-0.5 rounded-full" 
                    :class="appointment.timeStatus === 'past' ? 'bg-gray-100 text-gray-500' :
                           appointment.timeStatus === 'current' ? 'bg-green-100 text-green-700' :
                           appointment.status === 'completed' ? 'bg-green-100 text-green-700' : 
                           appointment.status === 'approved' ? 'bg-blue-100 text-blue-700' : 
                           appointment.status === 'pending' ? 'bg-yellow-100 text-yellow-700' : 'bg-red-100 text-red-700'">
                {{ appointment.status }}
              </span>
              <span v-if="appointment.timeStatus === 'past'" class="text-[9px] sm:text-[10px] text-gray-400">
                Completed
              </span>
              <span v-else-if="appointment.timeStatus === 'current'" class="text-[9px] sm:text-[10px] text-green-600 font-medium">
                In Progress
              </span>
            </div>
          </div>
          
          <!-- Pet and Owner Info -->
          <div class="grid grid-cols-2 gap-4 mb-4">
            <div class="bg-white rounded-lg p-3 border border-gray-200">
              <p class="text-xs font-medium text-gray-500 mb-1">Pet Information</p>
              <p class="text-sm font-semibold text-gray-900">{{ appointment.petName }}</p>
              <p class="text-xs text-gray-600">{{ appointment.petType }}</p>
            </div>
            <div class="bg-white rounded-lg p-3 border border-gray-200">
              <p class="text-xs font-medium text-gray-500 mb-1">Owner</p>
              <p class="text-sm font-semibold text-gray-900">{{ appointment.ownerName }}</p>
              <p v-if="appointment.ownerPhone" class="text-xs text-gray-600 mt-1">{{ appointment.ownerPhone }}</p>
              <p v-if="appointment.ownerEmail" class="text-xs text-gray-600">{{ appointment.ownerEmail }}</p>
            </div>
          </div>
          
          <!-- Doctor Assignment - Highlighted -->
          <div class="bg-blue-50 rounded-lg p-4 border border-blue-200">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 bg-blue-500 rounded-full flex items-center justify-center">
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                </svg>
              </div>
              <div class="flex-1">
                <p class="text-xs font-medium text-blue-600 mb-1">ASSIGNED VETERINARY</p>
                <p class="text-lg font-bold text-gray-900">{{ appointment.doctorName }}</p>
              </div>
              <div class="text-right">
                <div class="w-2 h-2 bg-blue-500 rounded-full animate-pulse"></div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, watch, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { 
  Calendar, 
  Users,  
  ArrowUp,
  ArrowDown,
  CheckCircle,
  AlertCircle,
  Clock,
  FootprintsIcon,
  VideoIcon,
  PawPrint,
  Cat
} from 'lucide-vue-next'
import { Chart, registerables } from 'chart.js'
import dashboardStatsService from '@/services/dashboardStatsService'

// Initialize router
const router = useRouter()

// Register Chart.js components
Chart.register(...registerables)

// References for chart canvases
const appointmentsChart = ref(null)
const petDistributionChart = ref(null)

// Chart instances
let lineChart = null
let doughnutChart = null

// Loading states
const loading = ref(false)
const statsLoading = ref(false)

const selectedPeriod = ref('1')
const showMobileDropdown = ref(false)
const showVetDropdown = ref(false)

// Sidebar state
const showTodaySidebar = ref(false)
const selectedVetFilter = ref('')
const filteredTodayAppointments = ref([])
const availableVets = ref([])
const loadingVets = ref(false)
const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
const yAxisLabels = ['300', '250', '200', '150', '100', '50']

const periodOptions = [
  { value: '1', label: 'Current Month' },
  { value: '3', label: 'Last 3 Months' },
  { value: '6', label: 'Last 6 Months' },
  { value: '12', label: 'Last 12 Months' }
]

const stats = ref([
  { title: 'Total Appointments', value: '0', icon: Calendar, color: 'blue', trend: 'up', percentage: '0%' },
  { title: 'Active Patients', value: '0', icon: Users, color: 'green', trend: 'up', percentage: '0%' },
  { title: 'Online Session', value: '0', icon: VideoIcon, color: 'purple', trend: 'up', percentage: '0%' },
  { title: 'Walk-in Session', value: '0', icon: FootprintsIcon, color: 'orange', trend: 'down', percentage: '0%' }
])

const appointments = ref([])
const todaysAppointments = ref([])

const segments = ref([])

const recentActivities = ref([])

const filteredStats = computed(() => {
  return stats.value
})

const filteredAppointments = computed(() => {
  return appointments.value
})

const filteredTodaysAppointments = computed(() => {
  return todaysAppointments.value.map(appointment => {
    // Determine if appointment is past, current, or future
    const now = new Date();
    const appointmentTime = appointment.time; // e.g., "10:10 AM - 11:20 AM"
    
    // Extract start time from the time range
    let startTime = appointmentTime;
    if (appointmentTime && appointmentTime.includes('-')) {
      startTime = appointmentTime.split('-')[0].trim();
    }
    
    // Parse the start time
    let appointmentDateTime = new Date();
    if (startTime) {
      const timeMatch = startTime.match(/(\d{1,2}):(\d{2})\s*(am|pm)?/i);
      if (timeMatch) {
        let hours = parseInt(timeMatch[1]);
        const minutes = parseInt(timeMatch[2]);
        const period = timeMatch[3]?.toLowerCase();
        
        // Convert to 24-hour format
        if (period === 'pm' && hours !== 12) {
          hours += 12;
        } else if (period === 'am' && hours === 12) {
          hours = 0;
        }
        
        appointmentDateTime.setHours(hours, minutes, 0, 0);
      }
    }
    
    // Calculate duration in minutes
    let durationMinutes = 30; // default
    if (appointmentTime && appointmentTime.includes('-')) {
      const [start, end] = appointmentTime.split('-').map(t => t.trim());
      const startMatch = start.match(/(\d{1,2}):(\d{2})\s*(am|pm)?/i);
      const endMatch = end.match(/(\d{1,2}):(\d{2})\s*(am|pm)?/i);
      
      if (startMatch && endMatch) {
        let startHour = parseInt(startMatch[1]);
        const startMinute = parseInt(startMatch[2]);
        const startPeriod = startMatch[3]?.toLowerCase();
        
        let endHour = parseInt(endMatch[1]);
        const endMinute = parseInt(endMatch[2]);
        const endPeriod = endMatch[3]?.toLowerCase();
        
        // Convert to 24-hour format
        if (startPeriod === 'pm' && startHour < 12) startHour += 12;
        if (startPeriod === 'am' && startHour === 12) startHour = 0;
        if (endPeriod === 'pm' && endHour < 12) endHour += 12;
        if (endPeriod === 'am' && endHour === 12) endHour = 0;
        
        const startMinutes = startHour * 60 + startMinute;
        const endMinutes = endHour * 60 + endMinute;
        durationMinutes = endMinutes - startMinutes;
      }
    }
    
    // Calculate end time
    const endDateTime = new Date(appointmentDateTime.getTime() + durationMinutes * 60000);
    
    // Determine appointment status
    let timeStatus = 'future';
    if (now > endDateTime) {
      timeStatus = 'past';
    } else if (now >= appointmentDateTime && now <= endDateTime) {
      timeStatus = 'current';
    }
    
    return {
      ...appointment,
      timeStatus,
      appointmentDateTime,
      endDateTime
    };
  });
})

const filteredSegments = computed(() => {
  return segments.value
})

const filteredRecentActivities = computed(() => {
  return recentActivities.value
})

const totalPets = computed(() => filteredSegments.value.reduce((sum, segment) => sum + segment.value, 0))

const formatDate = (date, offset = 0) => {
  const d = new Date(date)
  d.setDate(d.getDate() + offset)
  return `${months[d.getMonth()]} ${d.getDate()}`
}

const generateNewData = () => {
  appointments.value = Array.from({ length: 12 }, () => Math.floor(Math.random() * (300 - 50 + 1) + 50))
}

const fetchDashboardData = async () => {
  try {
    loading.value = true
    statsLoading.value = true
    
    const periodMonths = parseInt(selectedPeriod.value)
    const dashboardStats = await dashboardStatsService.getDashboardStats(periodMonths)
    
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
    
  } catch (error) {
    console.error('Error fetching dashboard data:', error)
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

const getPeriodLabel = () => {
  const period = parseInt(selectedPeriod.value)
  return period === 1 ? 'Current Month' : `Last ${period} Months`
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

const getComparisonLabel = () => {
  const period = parseInt(selectedPeriod.value)
  if (period === 1) {
    return 'from previous month'
  } else {
    return `from previous ${period} months`
  }
}

const updateDashboard = async () => {
  await fetchDashboardData()
  updateCharts()
}

// Sidebar methods
const toggleTodaySidebar = async () => {
  showTodaySidebar.value = !showTodaySidebar.value
  if (showTodaySidebar.value) {
    await initializeTodaySidebar()
    // Prevent body scroll when sidebar is open
    document.body.style.overflow = 'hidden'
  } else {
    // Restore body scroll when sidebar is closed
    document.body.style.overflow = 'auto'
  }
}

const closeTodaySidebar = () => {
  showTodaySidebar.value = false
  // Restore body scroll when sidebar is closed
  document.body.style.overflow = 'auto'
}

const initializeTodaySidebar = async () => {
  // Set filtered appointments to all today's appointments
  filteredTodayAppointments.value = todaysAppointments.value
  
  // Fetch all active veterinaries from users collection
  loadingVets.value = true
  try {
    const { getFirestore, collection, getDocs, query, where } = await import('firebase/firestore')
    const db = getFirestore()
    
    const usersRef = collection(db, 'users')
    const q = query(
      usersRef,
      where('role', '==', 'veterinary'),
      where('status', '==', 'active')
    )
    
    const querySnapshot = await getDocs(q)
    const vets = []
    
    querySnapshot.forEach((doc) => {
      const data = doc.data()
      vets.push({
        doctorId: doc.id,
        doctorName: `${data.title === 'DVM' ? 'Dr.' : data.title || 'Dr.'} ${data.firstName || ''} ${data.lastName || ''}`.trim() || 'Unknown Veterinary'
      })
    })
    
    availableVets.value = vets
  } catch (error) {
    console.error('Error fetching veterinaries:', error)
    // Fallback to extracting from appointments if users fetch fails
    const vets = new Map()
    todaysAppointments.value.forEach(apt => {
      if (apt.doctorId && apt.doctorName) {
        vets.set(apt.doctorId, {
          doctorId: apt.doctorId,
          doctorName: apt.doctorName
        })
      }
    })
    availableVets.value = Array.from(vets.values())
  } finally {
    loadingVets.value = false
  }
}

const filterTodayAppointments = () => {
  if (!selectedVetFilter.value) {
    filteredTodayAppointments.value = todaysAppointments.value
  } else {
    filteredTodayAppointments.value = todaysAppointments.value.filter(
      apt => apt.doctorId === selectedVetFilter.value
    )
  }
}

const clearVetFilter = () => {
  selectedVetFilter.value = ''
  filteredTodayAppointments.value = todaysAppointments.value
}

// Handle view all activities click
const viewAllActivities = () => {
  router.push('/admin/appointments/approvedappointments')
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
      labels: getChartLabels(),
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

onMounted(async () => {
  selectedPeriod.value = '1'
  
  // Fetch initial dashboard data
  await fetchDashboardData()
  
  // Initialize charts after the DOM has been updated
  nextTick(() => {
    // Add a small delay to ensure DOM is fully rendered
    setTimeout(() => {
    updateCharts()
    }, 100)
  })
  
  // Close mobile dropdown when clicking outside
  document.addEventListener('click', (e) => {
    if (!e.target.closest('.mobile-dropdown-container')) {
      showMobileDropdown.value = false
    }
    if (!e.target.closest('.vet-dropdown-container')) {
      showVetDropdown.value = false
    }
  })
})

onBeforeUnmount(() => {
  // Restore body scroll when component is unmounted
  document.body.style.overflow = 'auto'
})
</script>