/* Disassembling 'arith-Ellesmere.bin' */
.amdcl2
.gpu Iceland
.64bit
.arch_minor 0
.arch_stepping 4
.driver_version 203603
.compile_options "-fno-bin-source -fno-bin-llvmir -fno-bin-amdil -fbin-exe -D__AMD__=1 -D__Ellesmere__=1 -D__Ellesmere=1 -D__IMAGE_SUPPORT__=1 -DFP_FAST_FMA=1 -cl-denorms-are-zero -m64 -Dcl_khr_fp64=1 -Dcl_amd_fp64=1 -Dcl_khr_global_int32_base_atomics=1 -Dcl_khr_global_int32_extended_atomics=1 -Dcl_khr_local_int32_base_atomics=1 -Dcl_khr_local_int32_extended_atomics=1 -Dcl_khr_int64_base_atomics=1 -Dcl_khr_int64_extended_atomics=1 -Dcl_khr_3d_image_writes=1 -Dcl_khr_byte_addressable_store=1 -Dcl_khr_fp16=1 -Dcl_khr_gl_sharing=1 -Dcl_khr_gl_depth_images=1 -Dcl_amd_device_attribute_query=1 -Dcl_amd_vec3=1 -Dcl_amd_printf=1 -Dcl_amd_media_ops=1 -Dcl_amd_media_ops2=1 -Dcl_amd_popcnt=1 -Dcl_khr_d3d10_sharing=1 -Dcl_khr_d3d11_sharing=1 -Dcl_khr_dx9_media_sharing=1 -Dcl_khr_image2d_from_buffer=1 -Dcl_khr_spir=1 -Dcl_khr_subgroups=1 -Dcl_khr_gl_event=1 -Dcl_khr_depth_images=1 -Dcl_khr_mipmap_image=1 -Dcl_khr_mipmap_image_writes=1 -Dcl_amd_liquid_flash=1 -Dcl_amd_planar_yuv=1"
.acl_version "AMD-COMP-LIB-v0.8 (0.0.SC_BUILD_NUMBER)"
.kernel cpFACE
    .config
        .dims x
        .cws 64, 1, 1
        .sgprsnum 13
        .vgprsnum 4
        .floatmode 0xc0
        .pgmrsrc1 0x00ac0040
        .pgmrsrc2 0x0000008c
        .dx10clamp
        .ieeemode
        .useargs
        .priority 0
        .arg _.global_offset_0, "size_t", long
        .arg _.global_offset_1, "size_t", long
        .arg _.global_offset_2, "size_t", long
        .arg _.printf_buffer, "size_t", void*, global, , rdonly
        .arg _.vqueue_pointer, "size_t", long
        .arg _.aqlwrap_pointer, "size_t", long
        .arg data, "int*", int*, global, 
        .arg x, "int", int
    .text
        s_lshl_b32      s0, s6, 6               #s0 = s6 * 64 (== group_id * local_size)
        v_mov_b32       v2, 0xface
        s_load_dwordx2  s[2:3], s[4:5], 0x0     #s2 = get_global_offset(0)
        s_load_dwordx2  s[4:5], s[4:5], 0x30    #s4 = data (address of data)
        s_waitcnt       lgkmcnt(0)              
        s_add_u32       s0, s0, s2              #s0 += s2 now s0 = s6*64 + s2, 
        v_add_u32       v0, vcc, s0, v0         #v0 += s0 now v0 = get_global_id(0)
        v_mov_b32       v1, 0
        v_lshlrev_b64   v[0:1], 2, v[0:1]       #v[0:1] *= 4 (1byte address -> 4 bytes (uint) address)
        v_add_u32       v0, vcc, s4, v0         #v0 += address of data; now v0 == &(data[get_global_id(0)]) -- least significant part
        v_mov_b32       v3, s5                  #v3 == &(data[get_global_id(0)]) -- most significant part
        v_addc_u32      v1, vcc, v3, v1, vcc    #v1 == v3 now; could v3 be excluded?
        flat_store_dword v[0:1], v2             #data[get_global_id(0)] = 0xface
        s_endpgm
