<!-- components/common/Header.vue -->
<template>
  <header class="bg-[#3b82f6] sticky top-0 shadow-md z-50">
    <nav class="container mx-auto px-4 sm:px-6 py-4 flex items-center justify-between">
      <!-- Logo -->
      <router-link to="/" class="flex items-center">
        <img
          src="@/assets/media/images/logo/LogoProvet-removebg-preview.png"
          alt="ProVet Logo"
          class="h-10 md:h-12 w-auto mr-3"
        />
      </router-link>


      <!-- Navigation Links (Centered) - desktop -->
      <div class="flex-grow justify-center hidden md:flex">
        <ul class="flex space-x-5 lg:space-x-8">
          <li>
            <router-link
              to="/"
              class="text-white text-base md:text-lg font-medium hover:text-blue-800 transition duration-200 pb-2"
              :class="{ 'border-b-2 border-white': $route.path === '/' }"
            >
              Home
            </router-link>
          </li>
          <li>
            <router-link
              to="/about"
              class="text-white text-base md:text-lg font-medium hover:text-blue-800 transition duration-200 pb-2"
              :class="{ 'border-b-2 border-white': $route.path === '/about' }"
            >
              About Us
            </router-link>
          </li>
          <li>
            <router-link
              to="/service"
              class="text-white text-base md:text-lg font-medium hover:text-blue-800 transition duration-200 pb-2"
              :class="{ 'border-b-2 border-white': $route.path === '/service' }"
            >
              Services
            </router-link>
          </li>
          <li>
            <router-link
              to="/contact"
              class="text-white text-base md:text-lg font-medium hover:text-blue-800 transition duration-200 pb-2"
              :class="{ 'border-b-2 border-white': $route.path === '/contact' }"
            >
              Contact Us
            </router-link>
          </li>
        </ul>
      </div>


      <!-- Right side: desktop auth buttons + mobile menu button -->
      <div class="flex items-center">
        <div class="hidden md:flex space-x-4">
          <router-link
            to="/auth/Login"
            class="bg-white text-[#2563eb] hover:bg-blue-100 px-7 py-2 rounded-full text-lg font-semibold transition duration-300 ease-in-out transform hover:scale-105 shadow-md"
          >
            Login
          </router-link>
          <router-link
            to="/auth/Register"
            class="bg-[#1e40af] text-white hover:bg-[#1b3a94] px-7 py-2 rounded-full text-lg font-semibold transition duration-300 ease-in-out transform hover:scale-105 shadow-md"
          >
            Register
          </router-link>
        </div>


        <!-- Mobile menu toggle -->
        <button
          class="md:hidden inline-flex items-center justify-center p-1.5 rounded-md text-white hover:bg-blue-500 focus:outline-none focus:ring-2 focus:ring-white"
          @click="isMobileOpen = !isMobileOpen"
          aria-label="Toggle menu"
        >
          <!-- Custom hamburger: three rounded bars, bottom shorter -->
          <div v-if="!isMobileOpen" class="flex flex-col items-end" aria-hidden="true">
            <span class="block h-1 w-6 bg-white rounded-full"></span>
            <span class="block h-1 w-6 bg-white rounded-full mt-1"></span>
            <span class="block h-1 w-4 bg-white rounded-full mt-1"></span>
          </div>
          <svg v-else xmlns="http://www.w3.org/2000/svg" class="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>
    </nav>


    <!-- Mobile menu -->
    <div v-show="isMobileOpen" class="md:hidden bg-[#3b82f6] border-t border-blue-400">
      <div class="container mx-auto px-4 py-4 space-y-3">
        <router-link
          to="/"
          class="block text-white text-base font-medium py-2"
          @click="closeMobile()"
          :class="{ 'underline': $route.path === '/' }"
        >Home</router-link>
        <router-link
          to="/about"
          class="block text-white text-base font-medium py-2"
          @click="closeMobile()"
          :class="{ 'underline': $route.path === '/about' }"
        >About Us</router-link>
        <router-link
          to="/service"
          class="block text-white text-base font-medium py-2"
          @click="closeMobile()"
          :class="{ 'underline': $route.path === '/service' }"
        >Services</router-link>
        <router-link
          to="/contact"
          class="block text-white text-base font-medium py-2"
          @click="closeMobile()"
          :class="{ 'underline': $route.path === '/contact' }"
        >Contact Us</router-link>


        <div class="pt-2 flex items-center space-x-3">
          <router-link
            to="/auth/Login"
            class="flex-1 text-center bg-white text-[#2563eb] hover:bg-blue-100 px-5 py-2 rounded-full text-base font-semibold transition duration-300 shadow-md"
            @click="closeMobile()"
          >Login</router-link>
          <router-link
            to="/auth/Register"
            class="flex-1 text-center bg-[#1e40af] text-white hover:bg-[#1b3a94] px-5 py-2 rounded-full text-base font-semibold transition duration-300 shadow-md"
            @click="closeMobile()"
          >Register</router-link>
        </div>
      </div>
    </div>
  </header>
</template>


<script setup>
import { ref } from 'vue'


const isMobileOpen = ref(false)


function closeMobile() {
  isMobileOpen.value = false
}
</script>

