/* Disassembling 'prefix.bin' */
.gallium
.gpu Oland
.64bit
.driver_version 170000
.llvm_version 40000
.kernel prefix_sum
    .args
        .arg global, 8, 8, 8, zext, general
        .arg global, 8, 8, 8, zext, general
        .arg global, 8, 8, 8, zext, general
        .arg scalar, 4, 4, 4, zext, griddim
        .arg scalar, 4, 4, 4, zext, gridoffset
    .config
        .dims x
        .sgprsnum 24
        .vgprsnum 12
        .dx10clamp
        .ieeemode
        .floatmode 0xf0
        .priority 0
        .localsize 2048
        .userdatanum 8
        .pgmrsrc1 0x00af0082
        .pgmrsrc2 0x00040090
        .spilledsgprs 0
        .spilledvgprs 0
        .hsa_dims x
        .hsa_sgprsnum 24
        .hsa_vgprsnum 12
        .hsa_dx10clamp
        .hsa_ieeemode
        .hsa_floatmode 0xf0
        .hsa_priority 0
        .hsa_localsize 2048
        .hsa_userdatanum 8
        .hsa_pgmrsrc1 0x00af0082
        .hsa_pgmrsrc2 0x00040090
        .codeversion 1, 2
        .machine 1, 6, 0, 1
        .kernel_code_entry_offset 0x100
        .use_private_segment_buffer
        .use_dispatch_ptr
        .use_kernarg_segment_ptr
        .private_elem_size 4
        .use_ptr64
        .workgroup_group_segment_size 2048
        .kernarg_segment_size 40
        .wavefront_sgpr_count 18
        .workitem_vgpr_count 9
        .kernarg_segment_align 16
        .group_segment_align 16
        .private_segment_align 16
        .wavefront_size 64
        .call_convention 0xffffffff
    .control_directive
        .fill 128, 1, 0x00
.kernel add
    .args
        .arg global, 8, 8, 8, zext, general
        .arg global, 8, 8, 8, zext, general
        .arg scalar, 4, 4, 4, zext, griddim
        .arg scalar, 4, 4, 4, zext, gridoffset
    .config
        .dims x
        .sgprsnum 16
        .vgprsnum 8
        .dx10clamp
        .ieeemode
        .floatmode 0xf0
        .priority 0
        .userdatanum 8
        .pgmrsrc1 0x00af0041
        .pgmrsrc2 0x00000090
        .spilledsgprs 0
        .spilledvgprs 0
        .hsa_dims x
        .hsa_sgprsnum 16
        .hsa_vgprsnum 8
        .hsa_dx10clamp
        .hsa_ieeemode
        .hsa_floatmode 0xf0
        .hsa_priority 0
        .hsa_userdatanum 8
        .hsa_pgmrsrc1 0x00af0041
        .hsa_pgmrsrc2 0x00000090
        .codeversion 1, 2
        .machine 1, 6, 0, 1
        .kernel_code_entry_offset 0x100
        .use_private_segment_buffer
        .use_dispatch_ptr
        .use_kernarg_segment_ptr
        .private_elem_size 4
        .use_ptr64
        .kernarg_segment_size 32
        .wavefront_sgpr_count 12
        .workitem_vgpr_count 5
        .kernarg_segment_align 16
        .group_segment_align 16
        .private_segment_align 16
        .wavefront_size 64
        .call_convention 0xffffffff
    .control_directive
        .fill 128, 1, 0x00
.text
prefix_sum:
.skip 256
/*000000000100*/ s_load_dwordx4  s[12:15], s[6:7], 0x0
/*000000000104*/ s_load_dwordx4  s[0:3], s[6:7], 0x4
/*000000000108*/ s_load_dword    s6, s[4:5], 0x1
/*00000000010c*/ v_lshlrev_b32   v7, 1, v0
/*000000000110*/ v_mov_b32       v2, 0
/*000000000114*/ s_mov_b32       s9, 0
/*000000000118*/ s_mov_b32       s7, 0xf000
/*000000000120*/ s_waitcnt       lgkmcnt(0)
/*000000000124*/ s_and_b32       s10, s6, 0xffff
/*00000000012c*/ s_lshl_b32      s11, s10, 1
/*000000000130*/ s_mul_i32       s6, s11, s8
/*000000000134*/ v_add_i32       v1, vcc, s6, v7
/*000000000138*/ v_lshl_b64      v[3:4], v[1:2], 2
/*000000000140*/ s_mov_b32       s6, s9
/*000000000144*/ s_mov_b64       s[4:5], s[12:13]
/*000000000148*/ buffer_load_dwordx2 v[5:6], v[3:4], s[4:7], 0 addr64
/*000000000150*/ s_mov_b32       s12, 1
/*000000000154*/ v_lshlrev_b32   v3, 3, v0
/*000000000158*/ s_mov_b32       m0, -1
/*00000000015c*/ v_or_b32        v4, 1, v7
/*000000000160*/ s_cmp_lt_i32    s10, 1
/*000000000164*/ s_waitcnt       vmcnt(0)
/*000000000168*/ ds_write2_b32   v3, v5, v6 offset1:1
/*000000000170*/ s_cbranch_scc1  .L484_0
/*000000000174*/ s_mov_b32       s12, 1
/*000000000178*/ s_mov_b32       s5, s10
/*00000000017c*/ s_branch        .L404_0
.L384_0:
/*000000000180*/ s_or_b64        exec, exec, s[6:7]
/*000000000184*/ s_lshr_b32      s5, s5, 1
/*000000000188*/ s_lshl_b32      s12, s12, 1
/*00000000018c*/ s_cmp_eq_u32    s5, 0
/*000000000190*/ s_cbranch_scc1  .L484_0
.L404_0:
/*000000000194*/ v_cmp_gt_u32    vcc, s5, v0
/*000000000198*/ s_waitcnt       lgkmcnt(0)
/*00000000019c*/ s_barrier
/*0000000001a0*/ s_and_saveexec_b64 s[6:7], vcc
/*0000000001a4*/ s_cbranch_execz .L384_0
/*0000000001a8*/ v_mul_lo_u32    v5, s12, v4
/*0000000001b0*/ s_lshl_b32      s4, s12, 2
/*0000000001b4*/ v_lshlrev_b32   v5, 2, v5
/*0000000001b8*/ v_add_i32       v5, vcc, -4, v5
/*0000000001bc*/ v_add_i32       v6, vcc, s4, v5
/*0000000001c0*/ ds_read_b32     v5, v5
/*0000000001c8*/ ds_read_b32     v7, v6
/*0000000001d0*/ s_waitcnt       lgkmcnt(0)
/*0000000001d4*/ v_add_f32       v5, v5, v7
/*0000000001d8*/ ds_write_b32    v6, v5
/*0000000001e0*/ s_branch        .L384_0
.L484_0:
/*0000000001e4*/ s_mov_b32       s2, 0
/*0000000001e8*/ v_cmp_eq_u32    vcc, 0, v0
/*0000000001ec*/ s_and_saveexec_b64 s[6:7], vcc
/*0000000001f0*/ s_cbranch_execz .L568_0
/*0000000001f4*/ s_lshl_b32      s3, s11, 2
/*0000000001f8*/ s_add_i32       s5, s3, -4
/*0000000001fc*/ v_mov_b32       v7, s5
/*000000000200*/ ds_read_b32     v8, v7
/*000000000208*/ s_lshl_b64      s[4:5], s[8:9], 2
/*00000000020c*/ s_mov_b32       s3, 0xf000
/*000000000214*/ v_mov_b32       v5, s4
/*000000000218*/ s_mov_b64       s[2:3], s[2:3]
/*00000000021c*/ v_mov_b32       v6, s5
/*000000000220*/ s_waitcnt       lgkmcnt(0)
/*000000000224*/ buffer_store_dword v8, v[5:6], s[0:3], 0 addr64
/*00000000022c*/ v_mov_b32       v5, 0
/*000000000230*/ ds_write_b32    v7, v5
.L568_0:
/*000000000238*/ s_or_b64        exec, exec, s[6:7]
/*00000000023c*/ s_cmp_eq_u32    s10, 0
/*000000000240*/ s_cbranch_scc1  .L708_0
/*000000000244*/ s_mov_b32       s0, 1
/*000000000248*/ s_branch        .L604_0
.L588_0:
/*00000000024c*/ s_or_b64        exec, exec, s[8:9]
/*000000000250*/ s_lshl_b32      s0, s0, 1
/*000000000254*/ s_cmp_gt_u32    s0, s10
/*000000000258*/ s_cbranch_scc1  .L708_0
.L604_0:
/*00000000025c*/ s_lshr_b32      s12, s12, 1
/*000000000260*/ v_cmp_gt_u32    vcc, s0, v0
/*000000000264*/ s_waitcnt       vmcnt(0) & expcnt(0) & lgkmcnt(0)
/*000000000268*/ s_barrier
/*00000000026c*/ s_and_saveexec_b64 s[8:9], vcc
/*000000000270*/ s_cbranch_execz .L588_0
/*000000000274*/ v_mul_lo_u32    v5, s12, v4
/*00000000027c*/ s_lshl_b32      s11, s12, 2
/*000000000280*/ v_lshlrev_b32   v5, 2, v5
/*000000000284*/ v_add_i32       v5, vcc, -4, v5
/*000000000288*/ v_add_i32       v6, vcc, s11, v5
/*00000000028c*/ ds_read_b32     v7, v5
/*000000000294*/ ds_read_b32     v8, v6
/*00000000029c*/ s_waitcnt       lgkmcnt(0)
/*0000000002a0*/ ds_write_b32    v5, v8
/*0000000002a8*/ ds_read_b32     v5, v6
/*0000000002b0*/ s_waitcnt       lgkmcnt(0)
/*0000000002b4*/ v_add_f32       v5, v7, v5
/*0000000002b8*/ ds_write_b32    v6, v5
/*0000000002c0*/ s_branch        .L588_0
.L708_0:
/*0000000002c4*/ s_waitcnt       vmcnt(0) & expcnt(0) & lgkmcnt(0)
/*0000000002c8*/ s_barrier
/*0000000002cc*/ ds_read2_b32    v[3:4], v3 offset1:1
/*0000000002d4*/ v_lshl_b64      v[0:1], v[1:2], 2
/*0000000002dc*/ s_mov_b32       s11, 0xf000
/*0000000002e4*/ s_mov_b32       s10, 0
/*0000000002e8*/ s_mov_b64       s[8:9], s[14:15]
/*0000000002ec*/ s_waitcnt       lgkmcnt(0)
/*0000000002f0*/ buffer_store_dwordx2 v[3:4], v[0:1], s[8:11], 0 addr64
/*0000000002f8*/ s_endpgm
/*0000000002fc*/ s_nop           0x0
add:
.skip 256
/*000000000400*/ s_load_dwordx4  s[0:3], s[6:7], 0x0
/*000000000404*/ s_load_dword    s4, s[4:5], 0x1
/*000000000408*/ s_mov_b32       s9, 0
/*00000000040c*/ v_lshlrev_b32   v4, 1, v0
/*000000000410*/ v_mov_b32       v1, 0
/*000000000414*/ s_waitcnt       lgkmcnt(0)
/*000000000418*/ s_and_b32       s6, s4, 0xffff
/*000000000420*/ s_lshl_b64      s[4:5], s[8:9], 2
/*000000000424*/ s_add_u32       s4, s2, s4
/*000000000428*/ s_mul_i32       s6, s6, s8
/*00000000042c*/ s_addc_u32      s5, s3, s5
/*000000000430*/ s_lshl_b32      s6, s6, 1
/*000000000434*/ v_add_i32       v0, vcc, s6, v4
/*000000000438*/ v_lshl_b64      v[2:3], v[0:1], 2
/*000000000440*/ s_mov_b32       s3, 0xf000
/*000000000448*/ s_mov_b32       s2, s9
/*00000000044c*/ v_or_b32        v0, 1, v4
/*000000000450*/ buffer_load_dword v4, v[2:3], s[0:3], 0 addr64
/*000000000458*/ v_add_i32       v0, vcc, s6, v0
/*00000000045c*/ s_load_dword    s6, s[4:5], 0x0
/*000000000460*/ v_lshl_b64      v[0:1], v[0:1], 2
/*000000000468*/ s_waitcnt       vmcnt(0) & lgkmcnt(0)
/*00000000046c*/ v_add_f32       v4, s6, v4
/*000000000470*/ buffer_store_dword v4, v[2:3], s[0:3], 0 addr64
/*000000000478*/ buffer_load_dword v2, v[0:1], s[0:3], 0 addr64
/*000000000480*/ s_load_dword    s4, s[4:5], 0x0
/*000000000484*/ s_waitcnt       vmcnt(0) & lgkmcnt(0)
/*000000000488*/ v_add_f32       v2, s4, v2
/*00000000048c*/ buffer_store_dword v2, v[0:1], s[0:3], 0 addr64
/*000000000494*/ s_endpgm
