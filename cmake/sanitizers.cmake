# =============================================================================
# Sanitizer Support for OBS Studio
# vantisCorp fork - Phase 2 Quality Improvements
#
# This module provides options to enable various sanitizers:
# - Address Sanitizer (ASan): Detects memory errors
# - Thread Sanitizer (TSan): Detects data races
# - Undefined Behavior Sanitizer (UBSan): Detects undefined behavior
# - Memory Sanitizer (MSan): Detects uninitialized reads (Clang only)
# - Leak Sanitizer (LSan): Detects memory leaks
# =============================================================================

option(ENABLE_ASAN "Enable Address Sanitizer" OFF)
option(ENABLE_TSAN "Enable Thread Sanitizer" OFF)
option(ENABLE_UBSAN "Enable Undefined Behavior Sanitizer" OFF)
option(ENABLE_MSAN "Enable Memory Sanitizer (Clang only)" OFF)
option(ENABLE_LSAN "Enable Leak Sanitizer" OFF)

# Check for compiler support
include(CheckCCompilerFlag)
include(CheckCXXCompilerFlag)

# =============================================================================
# Address Sanitizer (ASan)
# Detects: Out-of-bounds accesses, use-after-free, double-free, memory leaks
# =============================================================================
if(ENABLE_ASAN)
	message(STATUS "Enabling Address Sanitizer (ASan)")

	set(ASAN_FLAGS "-fsanitize=address -fno-omit-frame-pointer")

	check_c_compiler_flag("-fsanitize=address" C_COMPILER_SUPPORTS_ASAN)
	check_cxx_compiler_flag("-fsanitize=address" CXX_COMPILER_SUPPORTS_ASAN)

	if(C_COMPILER_SUPPORTS_ASAN AND CXX_COMPILER_SUPPORTS_ASAN)
		add_compile_options(${ASAN_FLAGS})
		add_link_options(${ASAN_FLAGS})

		# Additional options for better diagnostics
		set(ASAN_OPTIONS "detect_leaks=1:detect_stack_use_after_return=1:check_initialization_order=1")
		set(ENV{ASAN_OPTIONS} ${ASAN_OPTIONS})
	else()
		message(WARNING "Address Sanitizer not supported by compiler")
	endif()
endif()

# =============================================================================
# Thread Sanitizer (TSan)
# Detects: Data races, deadlocks
# Note: Incompatible with ASan, MSan
# =============================================================================
if(ENABLE_TSAN)
	if(ENABLE_ASAN OR ENABLE_MSAN)
		message(FATAL_ERROR "Thread Sanitizer is incompatible with Address/Memory Sanitizer")
	endif()

	message(STATUS "Enabling Thread Sanitizer (TSan)")

	set(TSAN_FLAGS "-fsanitize=thread -fno-omit-frame-pointer")

	check_c_compiler_flag("-fsanitize=thread" C_COMPILER_SUPPORTS_TSAN)
	check_cxx_compiler_flag("-fsanitize=thread" CXX_COMPILER_SUPPORTS_TSAN)

	if(C_COMPILER_SUPPORTS_TSAN AND CXX_COMPILER_SUPPORTS_TSAN)
		add_compile_options(${TSAN_FLAGS})
		add_link_options(${TSAN_FLAGS})
	else()
		message(WARNING "Thread Sanitizer not supported by compiler")
	endif()
endif()

# =============================================================================
# Undefined Behavior Sanitizer (UBSan)
# Detects: Division by zero, null pointer dereference, signed integer overflow
# =============================================================================
if(ENABLE_UBSAN)
	message(STATUS "Enabling Undefined Behavior Sanitizer (UBSan)")

	set(UBSAN_FLAGS "-fsanitize=undefined -fno-omit-frame-pointer")

	check_c_compiler_flag("-fsanitize=undefined" C_COMPILER_SUPPORTS_UBSAN)
	check_cxx_compiler_flag("-fsanitize=undefined" CXX_COMPILER_SUPPORTS_UBSAN)

	if(C_COMPILER_SUPPORTS_UBSAN AND CXX_COMPILER_SUPPORTS_UBSAN)
		add_compile_options(${UBSAN_FLAGS})
		add_link_options(${UBSAN_FLAGS})
	else()
		message(WARNING "Undefined Behavior Sanitizer not supported by compiler")
	endif()
endif()

# =============================================================================
# Memory Sanitizer (MSan) - Clang only
# Detects: Uninitialized memory reads
# Note: Incompatible with ASan, TSan
# =============================================================================
if(ENABLE_MSAN)
	if(ENABLE_ASAN OR ENABLE_TSAN)
		message(FATAL_ERROR "Memory Sanitizer is incompatible with Address/Thread Sanitizer")
	endif()

	if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
		message(WARNING "Memory Sanitizer is only supported by Clang")
	else()
		message(STATUS "Enabling Memory Sanitizer (MSan)")

		set(MSAN_FLAGS "-fsanitize=memory -fno-omit-frame-pointer")

		check_c_compiler_flag("-fsanitize=memory" C_COMPILER_SUPPORTS_MSAN)
		check_cxx_compiler_flag("-fsanitize=memory" CXX_COMPILER_SUPPORTS_MSAN)

		if(C_COMPILER_SUPPORTS_MSAN AND CXX_COMPILER_SUPPORTS_MSAN)
			add_compile_options(${MSAN_FLAGS})
			add_link_options(${MSAN_FLAGS})
		else()
			message(WARNING "Memory Sanitizer not supported by compiler")
		endif()
	endif()
endif()

# =============================================================================
# Leak Sanitizer (LSan)
# Detects: Memory leaks
# Note: On Linux, this is included in ASan by default
# =============================================================================
if(ENABLE_LSAN AND NOT ENABLE_ASAN)
	message(STATUS "Enabling Leak Sanitizer (LSan)")

	set(LSAN_FLAGS "-fsanitize=leak -fno-omit-frame-pointer")

	check_c_compiler_flag("-fsanitize=leak" C_COMPILER_SUPPORTS_LSAN)
	check_cxx_compiler_flag("-fsanitize=leak" CXX_COMPILER_SUPPORTS_LSAN)

	if(C_COMPILER_SUPPORTS_LSAN AND CXX_COMPILER_SUPPORTS_LSAN)
		add_compile_options(${LSAN_FLAGS})
		add_link_options(${LSAN_FLAGS})
	else()
		message(WARNING "Leak Sanitizer not supported by compiler")
	endif()
endif()

# =============================================================================
# Helper function for sanitizing specific targets
# =============================================================================
function(enable_sanitizers_for_target target)
	if(ENABLE_ASAN)
		target_compile_options(${target} PRIVATE "-fsanitize=address" "-fno-omit-frame-pointer")
		target_link_options(${target} PRIVATE "-fsanitize=address")
	endif()

	if(ENABLE_TSAN)
		target_compile_options(${target} PRIVATE "-fsanitize=thread" "-fno-omit-frame-pointer")
		target_link_options(${target} PRIVATE "-fsanitize=thread")
	endif()

	if(ENABLE_UBSAN)
		target_compile_options(${target} PRIVATE "-fsanitize=undefined" "-fno-omit-frame-pointer")
		target_link_options(${target} PRIVATE "-fsanitize=undefined")
	endif()

	if(ENABLE_MSAN AND CMAKE_CXX_COMPILER_ID MATCHES "Clang")
		target_compile_options(${target} PRIVATE "-fsanitize=memory" "-fno-omit-frame-pointer")
		target_link_options(${target} PRIVATE "-fsanitize=memory")
	endif()
endfunction()

# =============================================================================
# Summary
# =============================================================================
function(print_sanitizer_summary)
	message(STATUS "")
	message(STATUS "=== Sanitizer Configuration ===")
	message(STATUS "Address Sanitizer (ASan):    ${ENABLE_ASAN}")
	message(STATUS "Thread Sanitizer (TSan):     ${ENABLE_TSAN}")
	message(STATUS "UB Sanitizer (UBSan):        ${ENABLE_UBSAN}")
	message(STATUS "Memory Sanitizer (MSan):     ${ENABLE_MSAN}")
	message(STATUS "Leak Sanitizer (LSan):       ${ENABLE_LSAN}")
	message(STATUS "===============================")
	message(STATUS "")
endfunction()

# Print summary if any sanitizer is enabled
if(ENABLE_ASAN OR ENABLE_TSAN OR ENABLE_UBSAN OR ENABLE_MSAN OR ENABLE_LSAN)
	print_sanitizer_summary()
endif()