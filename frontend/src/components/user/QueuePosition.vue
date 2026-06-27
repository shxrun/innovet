<!-- components/user/QueuePosition.vue -->
<template>
  <div class="bg-white rounded-2xl p-4 shadow-sm border border-blue-50">
    <!-- Header -->
    <div class="flex items-center justify-between mb-4">
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
          <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
          </svg>
        </div>
        <div>
          <h3 class="text-lg font-semibold text-gray-800">Queue Position</h3>
          <p class="text-sm text-gray-500">Today's appointment status</p>
        </div>
      </div>
      <div class="text-right">
        <div class="text-xs text-gray-500">{{ formatCurrentTime() }}</div>
        <div class="text-xs text-gray-400">{{ formatCurrentDate() }}</div>
      </div>
    </div>

    <!-- Loading State - Skeleton -->
    <div v-if="shouldShowLoading" class="space-y-4">
      <!-- Header skeleton -->
      <div class="flex items-center justify-between mb-4">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 bg-gray-200 rounded-full animate-pulse"></div>
          <div>
            <div class="w-24 h-5 bg-gray-200 rounded animate-pulse mb-1"></div>
            <div class="w-32 h-4 bg-gray-200 rounded animate-pulse"></div>
          </div>
        </div>
        <div class="text-right">
          <div class="w-16 h-3 bg-gray-200 rounded animate-pulse mb-1"></div>
          <div class="w-20 h-3 bg-gray-200 rounded animate-pulse"></div>
        </div>
      </div>

      <!-- Current Status skeleton -->
      <div class="bg-gray-100 rounded-lg p-4 border border-gray-200">
        <div class="flex items-center justify-between mb-2">
          <div class="w-24 h-4 bg-gray-200 rounded animate-pulse"></div>
          <div class="w-16 h-6 bg-gray-200 rounded-full animate-pulse"></div>
        </div>
        <div class="text-center">
          <div class="w-12 h-8 bg-gray-200 rounded animate-pulse mx-auto mb-2"></div>
          <div class="w-20 h-4 bg-gray-200 rounded animate-pulse mx-auto"></div>
        </div>
      </div>

      <!-- Wait Time Estimate skeleton -->
      <div class="bg-gray-100 rounded-lg p-4 border border-gray-200">
        <div class="flex items-center justify-between mb-3">
          <div class="w-32 h-4 bg-gray-200 rounded animate-pulse"></div>
          <div class="w-4 h-4 bg-gray-200 rounded animate-pulse"></div>
        </div>
        <div class="text-center">
          <div class="w-20 h-6 bg-gray-200 rounded animate-pulse mx-auto mb-1"></div>
          <div class="w-24 h-4 bg-gray-200 rounded animate-pulse mx-auto"></div>
        </div>
      </div>

      <!-- Appointment Details skeleton -->
      <div class="bg-white border border-gray-200 rounded-lg p-4">
        <div class="flex items-center gap-3 mb-3">
          <div class="w-8 h-8 bg-gray-200 rounded-full animate-pulse"></div>
          <div>
            <div class="w-20 h-4 bg-gray-200 rounded animate-pulse mb-1"></div>
            <div class="w-16 h-3 bg-gray-200 rounded animate-pulse"></div>
          </div>
        </div>
        <div class="space-y-2">
          <div class="flex justify-between">
            <div class="w-16 h-3 bg-gray-200 rounded animate-pulse"></div>
            <div class="w-24 h-3 bg-gray-200 rounded animate-pulse"></div>
          </div>
          <div class="flex justify-between">
            <div class="w-12 h-3 bg-gray-200 rounded animate-pulse"></div>
            <div class="w-20 h-3 bg-gray-200 rounded animate-pulse"></div>
          </div>
          <div class="flex justify-between">
            <div class="w-16 h-3 bg-gray-200 rounded animate-pulse"></div>
            <div class="w-12 h-3 bg-gray-200 rounded animate-pulse"></div>
          </div>
        </div>
      </div>

      <!-- Queue Progress skeleton -->
      <div class="bg-gray-100 rounded-lg p-4 border border-gray-200">
        <div class="flex items-center justify-between mb-3">
          <div class="w-24 h-4 bg-gray-200 rounded animate-pulse"></div>
          <div class="w-20 h-3 bg-gray-200 rounded animate-pulse"></div>
        </div>
        <div class="relative">
          <div class="w-full bg-gray-200 rounded-full h-2">
            <div class="w-1/3 bg-gray-300 h-2 rounded-full animate-pulse"></div>
          </div>
          <div class="flex justify-between text-xs mt-2">
            <div class="w-6 h-3 bg-gray-200 rounded animate-pulse"></div>
            <div class="w-8 h-3 bg-gray-200 rounded animate-pulse"></div>
            <div class="w-6 h-3 bg-gray-200 rounded animate-pulse"></div>
          </div>
        </div>
      </div>
    </div>

    <!-- No Appointments Today -->
    <div v-else-if="!shouldShowLoading && !hasAppointmentsToday" class="text-center py-8">
      <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-3">
        <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
        </svg>
      </div>
      <p class="text-gray-600 font-medium">No appointments today</p>
      <p class="text-sm text-gray-500 mt-1">You're all caught up!</p>
    </div>

    <!-- Queue Information -->
    <div v-else-if="!shouldShowLoading" class="space-y-4">
      <!-- Current Status -->
      <div class="bg-blue-50 rounded-lg p-4 border border-blue-200">
        <div class="flex items-center justify-between mb-2">
          <span class="text-sm font-medium text-blue-800">Current Status</span>
          <span :class="`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(userAppointment.status)}`">
            {{ getStatusText(userAppointment.status) }}
          </span>
        </div>
        
        <div class="text-center">
          <div v-if="(userAppointment.status === 'approved' || userAppointment.status === 'processing') && queuePosition > 0" class="mb-3">
            <div class="text-3xl font-bold text-blue-600 mb-1">{{ queuePosition }}</div>
            <div class="text-sm text-blue-700">
              {{ queuePosition === 1 ? 'Next in line' : `${queuePosition}${getOrdinalSuffix(queuePosition)} in queue` }}
            </div>
          </div>
          
          <div v-else-if="userAppointment.status === 'in-progress'" class="mb-3">
            <div class="text-3xl font-bold text-green-600 mb-1">🎯</div>
            <div class="text-sm text-green-700">Currently consulting</div>
          </div>
          
          <div v-else-if="userAppointment.status === 'completed'" class="mb-3">
            <div class="text-3xl font-bold text-emerald-600 mb-1">✅</div>
            <div class="text-sm text-emerald-700">Appointment completed</div>
          </div>
        </div>
      </div>

      <!-- Wait Time Estimate -->
      <div v-if="(userAppointment.status === 'approved' || userAppointment.status === 'processing') && queuePosition > 0" class="bg-gray-50 rounded-lg p-4 border border-gray-200">
        <div class="flex items-center justify-between mb-3">
          <span class="text-sm font-medium text-gray-700">Estimated Wait Time</span>
          <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
          </svg>
        </div>
        
        <div class="text-center">
          <div class="text-2xl font-bold text-gray-800 mb-1">
            {{ estimatedWaitTime > 0 ? `~${estimatedWaitTime} min` : 'Starting soon' }}
          </div>
          <div class="text-sm text-gray-600">
            Est. start: {{ estimatedStartTime }}
          </div>
        </div>
      </div>

      <!-- Appointment Details -->
      <div class="bg-white border border-gray-200 rounded-lg p-4">
        <div class="flex items-center gap-3 mb-3">
          <div class="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center overflow-hidden">
            <img 
              :src="getPetImage()" 
              :alt="userAppointment.petNames?.join(', ') || 'Pet'" 
              class="w-full h-full object-cover"
            />
          </div>
          <div>
            <h4 class="font-medium text-gray-900">{{ userAppointment.petNames?.join(', ') || 'Your Pet' }}</h4>
            <p class="text-sm text-gray-500">{{ userAppointment.time || 'Time TBD' }}</p>
          </div>
        </div>
        
        <div class="space-y-2">
          <div class="flex justify-between text-sm">
            <span class="text-gray-500">Services:</span>
            <span class="text-gray-900 font-medium">
              {{ (userAppointment['Service Names'] || userAppointment.serviceNames || []).join(', ') || 'General Consultation' }}
            </span>
          </div>
          
          <div class="flex justify-between text-sm">
            <span class="text-gray-500">Doctor:</span>
            <span class="text-gray-900 font-medium">{{ getDoctorName(userAppointment.doctorId) }}</span>
          </div>
          
          <div class="flex justify-between text-sm">
            <span class="text-gray-500">Duration:</span>
            <span class="text-gray-900 font-medium">{{ userAppointment.duration || '30' }} min</span>
          </div>
        </div>
      </div>

      <!-- Queue Progress -->
      <div v-if="(userAppointment.status === 'approved' || userAppointment.status === 'processing') && queuePosition > 0" class="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-lg p-4 border border-blue-200">
        <div class="flex items-center justify-between mb-3">
          <span class="text-sm font-medium text-blue-800">Queue Progress</span>
          <span class="text-xs text-blue-600">{{ totalInQueue }} total patients</span>
        </div>
        
        <div class="relative">
          <div class="w-full bg-blue-200 rounded-full h-2">
            <div 
              class="bg-blue-600 h-2 rounded-full transition-all duration-500 ease-out"
              :style="{ width: `${getQueueProgress()}%` }"
            ></div>
          </div>
          
          <div class="flex justify-between text-xs text-blue-600 mt-2">
            <span>1st</span>
            <span>{{ queuePosition }}{{ getOrdinalSuffix(queuePosition) }}</span>
            <span>{{ totalInQueue }}{{ getOrdinalSuffix(totalInQueue) }}</span>
          </div>
        </div>
      </div>

    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/modules/authStore'
import { useAppointmentStore } from '@/stores/modules/appointmentStore'
import { collection, query, where, getDocs, orderBy, onSnapshot, doc, getDoc } from 'firebase/firestore'
import { db } from '@shared/firebase'

const router = useRouter()
const authStore = useAuthStore()
const appointmentStore = useAppointmentStore()

// State
const isLoading = ref(true)
const userAppointment = ref(null)
const queuePosition = ref(0)
const totalInQueue = ref(0)
const estimatedWaitTime = ref(0)
const estimatedStartTime = ref('')
const currentTime = ref(new Date())
const doctorInfo = ref(null)

// Default pet photo URL with white background (same as Dashboard)
const defaultPetPhotoURL = 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"%3E%3Crect width="24" height="24" fill="white"/%3E%3Cg fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"%3E%3Ccircle cx="11" cy="4" r="2"/%3E%3Ccircle cx="18" cy="8" r="2"/%3E%3Ccircle cx="20" cy="16" r="2"/%3E%3Cpath d="M9 10a5 5 0 0 1 5 5v3.5a3.5 3.5 0 0 1-6.84 1.045q-.64-2.065-2.7-2.705A3.5 3.5 0 0 1 5.5 10Z"/%3E%3C/g%3E%3C/svg%3E'

// Computed properties
const hasAppointmentsToday = computed(() => {
  return userAppointment.value && userAppointment.value.status !== 'cancelled'
})

// Smart loading state that considers appointmentStore cache
const shouldShowLoading = computed(() => {
  // If appointmentStore has cached data for this user, don't show loading
  if (authStore.user?.userId && appointmentStore.isDataCached(authStore.user.userId)) {
    return false
  }
  // Otherwise use the loading state
  return isLoading.value
})

// Get today's date range
const getTodayRange = () => {
  const today = new Date()
  const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate())
  const endOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 23, 59, 59, 999)
  return { startOfDay, endOfDay }
}

// Fetch user's appointment for today
const fetchUserAppointment = async (forceRefresh = false) => {
  try {
    isLoading.value = true
    
    if (!authStore.user?.userId) {
      console.log('No user ID, skipping appointment fetch')
      return
    }
    
    // Use appointmentStore to fetch appointments with caching
    const userAppointments = await appointmentStore.fetchAppointmentsByUserId(authStore.user.userId, forceRefresh)
    
    // Filter for today's appointments
    const today = new Date()
    const todayAppointments = userAppointments.filter(apt => {
      const aptDate = apt.date?.toDate ? apt.date.toDate() : new Date(apt.date)
      return aptDate.toDateString() === today.toDateString()
    })
    
    if (todayAppointments.length > 0) {
      // Get the first appointment for today
      const appointment = todayAppointments[0]
      console.log('QueuePosition: Found appointment with status:', appointment.status)
      userAppointment.value = appointment
      
      // Fetch doctor information
      if (appointment.doctorId) {
        doctorInfo.value = await fetchDoctorInfo(appointment.doctorId)
      }
      
      // Calculate queue position
      await calculateQueuePosition()
    } else {
      userAppointment.value = null
      queuePosition.value = 0
      totalInQueue.value = 0
      doctorInfo.value = null
    }
    
  } catch (error) {
    console.error('Error fetching user appointment:', error)
    userAppointment.value = null
  } finally {
    isLoading.value = false
  }
}

// Calculate queue position by checking all approved appointments for the doctor
const calculateQueuePosition = async () => {
  if (!userAppointment.value || !userAppointment.value.doctorId) return
  
  try {
    const { startOfDay, endOfDay } = getTodayRange()
    
    const appointmentsRef = collection(db, 'appointments')
    const q = query(
      appointmentsRef,
      where('doctorId', '==', userAppointment.value.doctorId),
      where('date', '>=', startOfDay),
      where('date', '<=', endOfDay),
      where('status', 'in', ['processing', 'approved', 'in-progress']),
      orderBy('date', 'asc')
    )
    
    const querySnapshot = await getDocs(q)
    const allAppointments = querySnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }))
    
    // Sort by date and time
    allAppointments.sort((a, b) => {
      const dateA = a.date?.toDate ? a.date.toDate() : new Date(a.date)
      const dateB = b.date?.toDate ? b.date.toDate() : new Date(b.date)
      
      if (dateA.getTime() !== dateB.getTime()) {
        return dateA - dateB
      }
      
      // If dates are the same, sort by time
      const timeA = a.time || '00:00'
      const timeB = b.time || '00:00'
      return timeA.localeCompare(timeB)
    })
    
    // Find user's position
    const userIndex = allAppointments.findIndex(apt => apt.id === userAppointment.value.id)
    
    if (userIndex !== -1) {
      queuePosition.value = userIndex + 1
      totalInQueue.value = allAppointments.length
      
      // Calculate estimated wait time
      calculateEstimatedWaitTime(userIndex, allAppointments)
    }
    
  } catch (error) {
    console.error('Error calculating queue position:', error)
  }
}

// Calculate estimated wait time
const calculateEstimatedWaitTime = (position, allAppointments) => {
  if (position === 0) {
    estimatedWaitTime.value = 0
    estimatedStartTime.value = 'Starting soon'
    return
  }
  
  // Calculate total wait time based on patients ahead
  let totalWaitTime = 0
  
  // Add time for patients ahead in the queue
  for (let i = 0; i < position; i++) {
    const patient = allAppointments[i]
    if (patient) {
      // Use duration from appointment or default to 30 minutes
      const duration = patient.duration || 30
      totalWaitTime += duration
      
      // Add buffer time between patients (5 minutes)
      if (i < position - 1) {
        totalWaitTime += 5
      }
    }
  }
  
  estimatedWaitTime.value = totalWaitTime
  
  // Calculate estimated start time
  const estimatedStart = new Date(currentTime.value.getTime() + (totalWaitTime * 60000))
  estimatedStartTime.value = estimatedStart.toLocaleTimeString('en-US', { 
    hour: '2-digit', 
    minute: '2-digit',
    hour12: true 
  })
}

// Helper functions
const getStatusColor = (status) => {
  const colors = {
    'pending': 'bg-yellow-100 text-yellow-800',
    'processing': 'bg-blue-100 text-blue-800',
    'approved': 'bg-green-100 text-green-800',
    'in-progress': 'bg-green-100 text-green-800',
    'completed': 'bg-emerald-100 text-emerald-800',
    'cancelled': 'bg-red-100 text-red-800',
    'rejected': 'bg-red-100 text-red-800',
    'ended': 'bg-slate-100 text-slate-800',
    'expired': 'bg-gray-100 text-gray-800'
  }
  return colors[status] || 'bg-gray-100 text-gray-800'
}

const getStatusText = (status) => {
  const texts = {
    'pending': 'Pending',
    'processing': 'Processing',
    'approved': 'Approved',
    'in-progress': 'In Progress',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
    'rejected': 'Rejected',
    'ended': 'Ended',
    'expired': 'Expired'
  }
  return texts[status] || status || 'Unknown'
}

const getOrdinalSuffix = (num) => {
  if (num === 1) return 'st'
  if (num === 2) return 'nd'
  if (num === 3) return 'rd'
  return 'th'
}

const getQueueProgress = () => {
  if (totalInQueue.value === 0) return 0
  return ((totalInQueue.value - queuePosition.value + 1) / totalInQueue.value) * 100
}

// Fetch doctor information from users collection
const fetchDoctorInfo = async (doctorId) => {
  if (!doctorId) return null
  
  try {
    const userRef = doc(db, 'users', doctorId)
    const userDoc = await getDoc(userRef)
    
    if (userDoc.exists()) {
      const userData = userDoc.data()
      return {
        userId: userDoc.id,
        firstName: userData.firstName,
        lastName: userData.lastName,
        title: userData.title,
        gender: userData.gender,
        specialty: userData.specialty,
        photoURL: userData.photoURL
      }
    }
    return null
  } catch (error) {
    console.error('Error fetching doctor info:', error)
    return null
  }
}

// Get doctor title based on gender (same logic as Appointments.vue)
const getDoctorTitle = (doctor) => {
  if (!doctor) return "Dr."
  
  // Check if gender is explicitly set
  if (doctor.gender) {
    return doctor.gender.toLowerCase() === "female" ? "Dra." : "Dr."
  }
  
  // If no gender is set, use Dr. as default
  return "Dr."
}

const getDoctorName = (doctorId) => {
  if (!doctorInfo.value) {
    return 'Dr. Veterinarian'
  }
  
  const title = getDoctorTitle(doctorInfo.value)
  return `${title} ${doctorInfo.value.firstName} ${doctorInfo.value.lastName}`
}

const getPetImage = () => {
  // For now, return the default pet placeholder
  // In the future, you could fetch the actual pet image from the appointment data
  return defaultPetPhotoURL
}

const formatCurrentTime = () => {
  return currentTime.value.toLocaleTimeString('en-US', { 
    hour: '2-digit', 
    minute: '2-digit',
    hour12: true 
  })
}

const formatCurrentDate = () => {
  return currentTime.value.toLocaleDateString('en-US', { 
    weekday: 'short',
    month: 'short',
    day: 'numeric'
  })
}

// Actions - removed refresh and details buttons as requested

// Removed auto-refresh functionality to match other dashboard sections

// Lifecycle
onMounted(async () => {
  // Check if appointmentStore already has cached data for this user
  if (authStore.user?.userId && appointmentStore.isDataCached(authStore.user.userId)) {
    console.log('QueuePosition: Using appointmentStore cached data, no loading needed')
    
    // Filter for today's appointments from store
    const today = new Date()
    const userAppointments = appointmentStore.getAppointmentsByUserId(authStore.user.userId)
    const todayAppointments = userAppointments.filter(apt => {
      const aptDate = apt.date?.toDate ? apt.date.toDate() : new Date(apt.date)
      return aptDate.toDateString() === today.toDateString()
    })
    
    if (todayAppointments.length > 0) {
      const appointment = todayAppointments[0]
      console.log('QueuePosition: Found cached appointment with status:', appointment.status)
      userAppointment.value = appointment
      
      // Fetch doctor information
      if (appointment.doctorId) {
        doctorInfo.value = await fetchDoctorInfo(appointment.doctorId)
      }
      
      await calculateQueuePosition()
    } else {
      userAppointment.value = null
      queuePosition.value = 0
      totalInQueue.value = 0
      doctorInfo.value = null
    }
    
    isLoading.value = false
    return
  }
  
  // Fetch fresh data if no cache
  await fetchUserAppointment()
})

onUnmounted(() => {
  // Cleanup if needed
})
</script>

<style scoped>
/* Add any specific styles here */
</style>


