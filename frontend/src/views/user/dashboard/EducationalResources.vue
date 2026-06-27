<!-- views/user/EducationalResources.vue -->
<template>
  <div class="bg-white rounded-2xl p-3 sm:p-4 md:p-6 text-gray-800 font-poppins">
        <!-- Header with Back Button -->
        <header class="flex flex-row justify-between items-center mb-3 sm:mb-6 md:mb-8 pb-2 sm:pb-4 border-b border-gray-200">
            <h1 class="text-lg sm:text-2xl md:text-3xl font-bold text-gray-900">Educational Resources</h1>
            <router-link to="/user/dashboard" class="flex items-center px-3 py-2 sm:px-4 sm:py-2 bg-blue-50 text-blue-700 rounded-full font-medium text-xs sm:text-sm transition-all duration-200 hover:bg-blue-100 w-fit">
              <ArrowLeftIcon class="w-3 h-3 sm:w-4 sm:h-4 mr-1 sm:mr-2" />
              <span class="hidden sm:inline">Return to Dashboard</span>
              <span class="sm:hidden">Back</span>
            </router-link>
          </header>

          <!-- Loading State with Skeleton Cards -->
          <div v-if="isLoading" class="py-2 sm:py-6 md:py-8">
            <div class="grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-3 gap-2 sm:gap-3 md:gap-4">
              <div v-for="i in 6" :key="i" class="bg-gradient-to-br from-gray-50 to-white border border-gray-100 rounded-xl overflow-hidden">
                <div class="aspect-[3/2] bg-gray-200 animate-pulse"></div>
                <div class="p-2">
                  <div class="w-[90%] h-3 rounded bg-gray-200 mb-1 animate-pulse"></div>
                  <div class="w-[60%] h-2 rounded bg-gray-200 animate-pulse"></div>
                </div>
              </div>
            </div>
          </div>

          <div v-else>
            <!-- Resource Categories Navigation and Search -->
            <div class="flex flex-col sm:flex-row sm:items-center gap-3 sm:gap-4 mb-3 sm:mb-6">
              <!-- Category Tabs -->
              <div class="flex overflow-x-auto gap-2 sm:gap-3 pb-2 sm:pb-0 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden flex-1">
                <button 
                  @click="selectedCategory = 'all'"
                  :class="[
                    'flex items-center px-3 py-2 sm:px-4 sm:py-2.5 rounded-full font-medium text-xs sm:text-sm whitespace-nowrap transition-all duration-200',
                    selectedCategory === 'all' 
                      ? 'bg-[#EBF5FF] text-[#0066FF] hover:bg-[#D1E7FF]' 
                      : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                  ]"
                  :aria-pressed="selectedCategory === 'all'"
                >
                  <LayersIcon class="w-3 h-3 sm:w-4 sm:h-4 mr-1 sm:mr-2" />
                  <span class="hidden sm:inline">All Resources</span>
                  <span class="sm:hidden">All</span>
                </button>
                <button 
                  v-for="category in resourceCategories" 
                  :key="category.id"
                  @click="selectedCategory = category.id"
                  :class="[
                    'flex items-center px-3 py-2 sm:px-4 sm:py-2.5 rounded-full font-medium text-xs sm:text-sm whitespace-nowrap transition-all duration-200',
                    selectedCategory === category.id 
                      ? 'bg-[#EBF5FF] text-[#0066FF] hover:bg-[#D1E7FF]' 
                      : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                  ]"
                  :aria-pressed="selectedCategory === category.id"
                >
                  <component :is="getCategoryIcon(category.name)" class="w-3 h-3 sm:w-4 sm:h-4 mr-1 sm:mr-2" />
                  <span>{{ category.name }}</span>
                </button>
              </div>
              
              <!-- Search Bar -->
              <div class="relative w-full sm:w-80 md:w-96 flex-shrink-0">
                <SearchIcon class="absolute left-3 sm:left-4 top-1/2 transform -translate-y-1/2 w-3 h-3 sm:w-4 sm:h-4 text-gray-500" />
                <input
                  type="text"
                  v-model="searchQuery"
                  placeholder="Search resources..."
                  class="w-full pl-8 sm:pl-10 pr-3 sm:pr-4 py-2.5 sm:py-3 rounded-full border border-gray-300 bg-white text-xs sm:text-sm transition-all duration-200 focus:outline-none focus:border-blue-400 focus:ring-3 focus:ring-blue-100"
                  aria-label="Search resources"
                />
              </div>
            </div>

            <!-- Resources Grid -->
            <div class="grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-3 gap-2 sm:gap-3 md:gap-4 mb-4 sm:mb-8">
              <div 
                v-for="resource in filteredResources" 
                :key="resource.id" 
                class="bg-gradient-to-br from-gray-50 to-white border border-gray-100 rounded-xl overflow-hidden hover:shadow-lg transition-all duration-300 hover:scale-[1.02] cursor-pointer focus:outline-none focus:ring-2 focus:ring-blue-500"
                @click="openResource(resource)"
                tabindex="0"
                @keydown.enter="openResource(resource)"
                role="button"
                :aria-label="`View ${resource.name}`"
              >
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
        </div>

            <!-- Empty State -->
            <div v-if="filteredResources.length === 0" class="flex flex-col items-center justify-center py-4 sm:py-12 md:py-16 px-2 sm:px-6 md:px-8 text-center">
              <div class="w-16 h-16 sm:w-20 sm:h-20 md:w-24 md:h-24 bg-gray-100 rounded-full flex items-center justify-center mb-4 sm:mb-6">
                <SearchXIcon class="w-8 h-8 sm:w-10 sm:h-10 md:w-12 md:h-12 text-gray-400" />
              </div>
              <h3 class="text-lg sm:text-xl font-semibold text-gray-800 mb-2">No resources found</h3>
              <p class="text-xs sm:text-sm text-gray-500 mb-4 sm:mb-6">Try adjusting your search or filter criteria</p>
              <button @click="resetFilters" class="px-4 sm:px-6 py-2 sm:py-3 bg-blue-600 text-white rounded-full font-medium transition-all duration-200 hover:bg-blue-700 text-xs sm:text-sm">
                Reset Filters
              </button>
            </div>
      </div>

          <!-- Resource Modal -->
          <div v-if="selectedResource" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-2 sm:p-4" @click.self="closeResource">
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
                <button @click="closeResource" class="p-1 rounded-full hover:bg-gray-100">
                  <XIcon class="w-5 h-5 text-gray-500" />
                </button>
              </div>
              
              <div v-if="selectedResource" class="p-4 sm:p-6 overflow-y-auto flex-1">
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
                
                <div class="text-gray-700 text-sm sm:text-base leading-6 sm:leading-7 max-w-none">
                  <p v-if="selectedResource.description" v-html="formatDescription(selectedResource.description)" class="mb-4"></p>
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
                
                <!-- Related Resources -->
                <div class="mt-6 sm:mt-8" v-if="relatedResources.length > 0">
                  <h3 class="text-base sm:text-lg font-medium mb-3 sm:mb-4">Related Resources</h3>
                  <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-4">
                    <div 
                      v-for="resource in relatedResources" 
                      :key="resource.id" 
                      class="flex border rounded-lg overflow-hidden hover:shadow-sm transition-shadow cursor-pointer"
                      @click="openResource(resource)"
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
                        <h4 class="text-xs sm:text-sm font-medium overflow-hidden" style="display: -webkit-box; -webkit-line-clamp: 2; line-clamp: 2; -webkit-box-orient: vertical;">{{ resource.name }}</h4>
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
import { ref, computed, onMounted, watch } from 'vue';
import { useRoute } from 'vue-router';
import { useResourceCategoryStore } from '@/stores/modules/ResourceCategoryStore';
import { storeToRefs } from 'pinia';
import { 
  Clock as ClockIcon,
  User as UserIcon,
  X as XIcon,
  Bookmark as BookmarkIcon,
  Share as ShareIcon,
  Search as SearchIcon,
  ArrowLeft as ArrowLeftIcon,
  BookOpen as BookOpenIcon,
  File as FileIcon,
  Play as PlayIcon,
  Layers as LayersIcon,
  FileText as FileTextIcon,
  Headphones as HeadphonesIcon,
  Image as ImageIcon,
  HelpCircle as HelpCircleIcon,
  Dog as DogIcon,
  Cat as CatIcon,
  Bird as BirdIcon,
  SearchX as SearchXIcon,
  Video as VideoIcon
} from 'lucide-vue-next';

const route = useRoute();
const resourceCategoryStore = useResourceCategoryStore();

// Use storeToRefs to maintain reactivity when destructuring store state
const { resourceCategories, resources, loading: storeLoading } = storeToRefs(resourceCategoryStore);

const selectedResource = ref(null);
const searchQuery = ref('');
const selectedCategory = ref('all');
const isLoading = ref(false);
const relatedResources = ref([]);

// Fetch data on component mount
onMounted(async () => {
  isLoading.value = true;
  try {
    // Fetch categories and resources from resourceCategories collection
    await resourceCategoryStore.fetchResourceCategories();
    await resourceCategoryStore.fetchResources();
    
    // Check if we have a resourceId param from the router
    if (route.params.resourceId) {
      const resourceId = route.params.resourceId;
      const resource = resources.value?.find(r => r.id === resourceId);
      if (resource) {
        openResource(resource);
      }
    }
  } catch (error) {
    console.error('Error fetching data:', error);
  } finally {
    isLoading.value = false;
  }
});

// Filter resources based on category and search query
const filteredResources = computed(() => {
  if (!resources.value) return [];
  
  let filteredItems = [...resources.value];
  
  // Filter by category
  if (selectedCategory.value !== 'all') {
    filteredItems = filteredItems.filter(resource => 
      resource.categoryId === selectedCategory.value
    );
  }
  
  // Filter by search query
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase().trim();
    
    // Only search if query has at least 2 characters
    if (query.length >= 2) {
      filteredItems = filteredItems.filter(resource => {
        const name = resource.name.toLowerCase();
        const description = resource.description ? resource.description.toLowerCase() : '';
        const categoryName = getCategoryName(resource.categoryId).toLowerCase();
        
        // More precise matching - check for exact word matches or phrase matches
        const queryWords = query.split(/\s+/).filter(word => word.length > 0);
        
        // Check if all query words are found in name, description, or category
        return queryWords.every(word => 
          name.includes(word) || 
          description.includes(word) ||
          categoryName.includes(word)
        );
      });
    } else if (query.length === 1) {
      // For single character, only match if it's at the start of a word
      filteredItems = filteredItems.filter(resource => {
        const name = resource.name.toLowerCase();
        const description = resource.description ? resource.description.toLowerCase() : '';
        
        // Check if query matches the start of any word
        const nameWords = name.split(/\s+/);
        const descWords = description.split(/\s+/);
        
        return nameWords.some(word => word.startsWith(query)) ||
               descWords.some(word => word.startsWith(query));
      });
    }
  }
  
  return filteredItems;
});

// Helper functions
function getTagColor(type) {
  const typeColors = {
    'Article': 'bg-blue-100 text-blue-700',
    'Video': 'bg-green-100 text-green-700',
    'Guide': 'bg-purple-100 text-purple-700',
    'Infographic': 'bg-orange-100 text-orange-700',
    'Document': 'bg-blue-100 text-blue-600',
    'Audio': 'bg-purple-100 text-purple-600',
    'Image': 'bg-green-100 text-green-600',
    'Other': 'bg-gray-100 text-gray-600'
  };
  
  return typeColors[type] || 'bg-gray-100 text-gray-700';
}

function getTagClass(type) {
  const typeClasses = {
    'Document': 'document',
    'Video': 'video',
    'Audio': 'audio',
    'Image': 'image',
    'Other': 'other'
  };
  
  return typeClasses[type] || 'other';
}

function getTypeIcon(type) {
  const typeIcons = {
    'Document': FileTextIcon,
    'Video': VideoIcon,
    'Audio': HeadphonesIcon,
    'Image': ImageIcon,
    'Other': HelpCircleIcon
  };
  
  return typeIcons[type] || HelpCircleIcon;
}

function getCategoryIcon(categoryName) {
  const categoryIcons = {
    'Dogs': DogIcon,
    'Cats': CatIcon,
    'Birds': BirdIcon
  };
  
  // Default to BookOpenIcon if no match or for other categories
  return categoryIcons[categoryName] || BookOpenIcon;
}

function getActionButtonText(type) {
  if (type === 'Video') return 'Watch Now';
  if (type === 'Audio') return 'Listen Now';
  if (type === 'Image') return 'View Now';
  return 'Read More';
}

function getReadTime(text) {
  if (!text) return '1 min read';
  
  // Average reading speed: 200 words per minute
  const wordCount = text.split(/\s+/).length;
  const minutes = Math.max(1, Math.ceil(wordCount / 200));
  
  return `${minutes} min read`;
}

function getExcerpt(text) {
  if (!text) return '';
  
  // Return first 120 characters as excerpt
  return text.length > 120 ? text.substring(0, 120) + '...' : text;
}

function formatDate(timestamp) {
  if (!timestamp) return 'Unknown date';
  
  const date = timestamp instanceof Date ? timestamp : new Date(timestamp);
  return date.toLocaleDateString('en-US', { 
    year: 'numeric', 
    month: 'short', 
    day: 'numeric' 
  });
}

function formatDescription(description) {
  if (!description) return '';
  
  // Convert line breaks to paragraphs
  return description
    .split('\n')
    .filter(paragraph => paragraph.trim() !== '')
    .map(paragraph => `<p>${paragraph}</p>`)
    .join('');
}

function getCategoryName(categoryId) {
  if (!resourceCategories.value) return 'Unknown Category';
  
  const category = resourceCategories.value.find(c => c.id === categoryId);
  return category ? category.name : 'Unknown Category';
}

function openResource(resource) {
  // First update related resources
  if (resources.value) {
    relatedResources.value = resources.value
      .filter(r => r.categoryId === resource.categoryId && r.id !== resource.id)
      .slice(0, 4); // Show up to 4 related resources
  }
  
  // Then set the selected resource
  selectedResource.value = resource;
  document.body.style.overflow = 'hidden'; // Prevent scrolling when modal is open
}

function closeResource() {
  document.body.style.overflow = ''; // Restore scrolling
  selectedResource.value = null;
}

function resetFilters() {
  searchQuery.value = '';
  selectedCategory.value = 'all';
}

// Reset pagination when filters change
watch([searchQuery, selectedCategory], () => {
  // If we had pagination, we would reset it here
});
</script>

