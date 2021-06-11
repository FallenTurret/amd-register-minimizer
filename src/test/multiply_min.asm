/* Disassembling 'multiply.bin' */
.gallium
.gpu Oland
.64bit
.driver_version 170000
.llvm_version 40000
.kernel matrix_mul
    .args
        .arg global, 8, 8, 8, zext, general
        .arg global, 8, 8, 8, zext, general
        .arg global, 8, 8, 8, zext, general
        .arg scalar, 4, 4, 4, zext, general
        .arg scalar, 4, 4, 4, zext, general
        .arg scalar, 4, 4, 4, zext, general
        .arg scalar, 4, 4, 4, zext, griddim
        .arg scalar, 4, 4, 4, zext, gridoffset
    .config
        .dims xy
        .sgprsnum 32
        .vgprsnum 24
        .dx10clamp
        .ieeemode
        .floatmode 0xf0
        .priority 0
        .localsize 3072
        .userdatanum 6
        .pgmrsrc1 0x00af00c5
        .pgmrsrc2 0x0006098c
        .spilledsgprs 0
        .spilledvgprs 0
        .hsa_dims xy
        .hsa_sgprsnum 32
        .hsa_vgprsnum 24
        .hsa_dx10clamp
        .hsa_ieeemode
        .hsa_floatmode 0xf0
        .hsa_priority 0
        .hsa_localsize 3072
        .hsa_userdatanum 6
        .hsa_pgmrsrc1 0x00af00c5
        .hsa_pgmrsrc2 0x0006098c
        .codeversion 1, 2
        .machine 1, 6, 0, 1
        .kernel_code_entry_offset 0x100
        .use_private_segment_buffer
        .use_kernarg_segment_ptr
        .private_elem_size 4
        .use_ptr64
        .workgroup_group_segment_size 3072
        .kernarg_segment_size 52
        .wavefront_sgpr_count 31
        .workitem_vgpr_count 24
        .kernarg_segment_align 16
        .group_segment_align 16
        .private_segment_align 16
        .wavefront_size 64
        .call_convention 0xffffffff
    .control_directive
        .fill 128, 1, 0x00
.text
matrix_mul:
.skip 256
/*000000000100*/ s_load_dwordx4  s[12:15], s[4:5], 0x0
/*000000000104*/ s_load_dwordx4  s[8:11], s[4:5], 0x4
/*000000000108*/ s_load_dwordx4  s[0:3], s[4:5], 0x6
/*00000000010c*/ s_lshl_b32      s16, s6, 4
/*000000000110*/ v_add_i32       v2, vcc, s16, v0
/*000000000114*/ s_mov_b32       s22, 0
/*000000000118*/ s_waitcnt       lgkmcnt(0)
/*00000000011c*/ s_lshr_b32      s25, s1, 4
/*000000000120*/ s_cmp_lg_u32    s25, 0
/*000000000124*/ s_cbranch_scc0  .L1188_0
/*000000000128*/ v_lshlrev_b32   v4, 2, v1
/*00000000012c*/ v_lshlrev_b32   v18, 6, v0
/*000000000130*/ s_movk_i32      s6, 0x800
/*000000000134*/ v_add_i32       v18, vcc, v18, v4
/*000000000138*/ v_add_i32       v20, vcc, s6, v18
/*00000000013c*/ s_mov_b32       s16, s14
/*000000000140*/ s_mov_b32       s17, s15
/*000000000144*/ s_lshr_b32      s24, s0, 1
/*000000000148*/ v_cmp_gt_u32    s[14:15], 16, v0
/*000000000150*/ v_lshlrev_b32   v21, 2, v0
/*000000000154*/ v_mul_lo_u32    v18, v0, s2
/*00000000015c*/ v_lshlrev_b32   v23, 6, v1
/*000000000160*/ v_add_i32       v7, vcc, v23, v21
/*000000000164*/ v_add_i32       v3, vcc, s24, v2
/*000000000168*/ v_mul_lo_u32    v22, v3, s1
/*000000000170*/ v_mul_lo_u32    v23, v2, s1
/*000000000178*/ v_add_i32       v10, vcc, s6, v4
/*00000000017c*/ v_add_i32       v0, vcc, v1, v18
/*000000000180*/ s_lshl_b32      s24, s7, 4
/*000000000184*/ v_add_i32       v11, vcc, s24, v0
/*000000000188*/ v_mov_b32       v0, 0
/*00000000018c*/ s_mov_b32       s20, s12
/*000000000190*/ s_mov_b32       s21, s13
/*000000000194*/ v_cmp_gt_u32    s[12:13], 16, v1
/*00000000019c*/ s_mov_b32       s26, s22
/*0000000001a0*/ v_add_i32       v5, vcc, v1, v22
/*0000000001a4*/ v_add_i32       v8, vcc, v1, v23
/*0000000001a8*/ s_lshl_b32      s0, s2, 4
/*0000000001ac*/ s_mov_b32       s23, 0xf000
/*0000000001b4*/ s_movk_i32      s6, 0x400
/*0000000001b8*/ s_movk_i32      s1, 0x480
/*0000000001bc*/ s_movk_i32      s27, 0x500
/*0000000001c0*/ s_movk_i32      s3, 0x580
/*0000000001c4*/ s_movk_i32      s28, 0x600
/*0000000001c8*/ s_movk_i32      s24, 0x680
/*0000000001cc*/ s_movk_i32      s4, 0x700
/*0000000001d0*/ s_movk_i32      s5, 0x780
/*0000000001d4*/ v_mov_b32       v4, v0
/*0000000001d8*/ s_mov_b32       m0, -1
/*0000000001dc*/ s_branch        .L1076_0
.L480_0:
/*0000000001e0*/ s_or_b64        exec, exec, s[10:11]
/*0000000001e4*/ v_add_i32       v18, vcc, s6, v21
/*0000000001e8*/ s_waitcnt       lgkmcnt(0)
/*0000000001ec*/ s_barrier
/*0000000001f0*/ ds_read2_b32    v[14:15], v21 offset1:16
/*0000000001f8*/ ds_read2_b32    v[16:17], v10 offset1:16
/*000000000200*/ ds_read2_b32    v[18:19], v18 offset1:16
/*000000000208*/ s_add_u32       s25, s25, -1
/*00000000020c*/ s_addc_u32      s26, s26, -1
/*000000000210*/ v_cmp_eq_u64    s[18:19], s[25:26], 0
/*000000000218*/ s_waitcnt       lgkmcnt(1)
/*00000000021c*/ v_mul_f32       v13, v14, v16
/*000000000220*/ v_mul_f32       v22, v15, v17
/*000000000224*/ s_waitcnt       lgkmcnt(0)
/*000000000228*/ v_mul_f32       v12, v18, v16
/*00000000022c*/ v_mul_f32       v18, v19, v17
/*000000000230*/ ds_read2_b32    v[14:15], v21 offset0:32 offset1:48
/*000000000238*/ ds_read2_b32    v[16:17], v10 offset0:32 offset1:48
/*000000000240*/ v_add_f32       v23, v13, v4
/*000000000244*/ v_add_f32       v13, v22, v23
/*000000000248*/ v_add_f32       v23, v12, v0
/*00000000024c*/ v_add_f32       v22, v18, v23
/*000000000250*/ s_waitcnt       lgkmcnt(0)
/*000000000254*/ v_mul_f32       v18, v14, v16
/*000000000258*/ v_add_i32       v14, vcc, s1, v21
/*00000000025c*/ v_mul_f32       v19, v15, v17
/*000000000260*/ ds_read2_b32    v[14:15], v14 offset1:16
/*000000000268*/ v_add_f32       v23, v18, v13
/*00000000026c*/ v_add_f32       v12, v19, v23
/*000000000270*/ v_add_i32       v5, vcc, 16, v5
/*000000000274*/ v_add_i32       v8, vcc, 16, v8
/*000000000278*/ s_waitcnt       lgkmcnt(0)
/*00000000027c*/ v_mul_f32       v9, v14, v16
/*000000000280*/ v_mul_f32       v13, v15, v17
/*000000000284*/ ds_read2_b32    v[14:15], v21 offset0:64 offset1:80
/*00000000028c*/ ds_read2_b32    v[16:17], v10 offset0:64 offset1:80
/*000000000294*/ v_add_f32       v9, v9, v22
/*000000000298*/ v_add_f32       v9, v13, v9
/*00000000029c*/ v_add_i32       v11, vcc, s0, v11
/*0000000002a0*/ s_waitcnt       lgkmcnt(0)
/*0000000002a4*/ v_mul_f32       v22, v14, v16
/*0000000002a8*/ v_add_i32       v14, vcc, s27, v21
/*0000000002ac*/ v_mul_f32       v23, v15, v17
/*0000000002b0*/ ds_read2_b32    v[14:15], v14 offset1:16
/*0000000002b8*/ v_add_f32       v13, v22, v12
/*0000000002bc*/ v_add_f32       v6, v23, v13
/*0000000002c0*/ s_waitcnt       lgkmcnt(0)
/*0000000002c4*/ v_mul_f32       v13, v14, v16
/*0000000002c8*/ v_mul_f32       v12, v15, v17
/*0000000002cc*/ ds_read2_b32    v[14:15], v21 offset0:96 offset1:112
/*0000000002d4*/ ds_read2_b32    v[16:17], v10 offset0:96 offset1:112
/*0000000002dc*/ v_add_f32       v13, v13, v9
/*0000000002e0*/ v_add_f32       v9, v12, v13
/*0000000002e4*/ s_waitcnt       lgkmcnt(0)
/*0000000002e8*/ v_mul_f32       v12, v14, v16
/*0000000002ec*/ v_add_i32       v14, vcc, s3, v21
/*0000000002f0*/ v_mul_f32       v13, v15, v17
/*0000000002f4*/ ds_read2_b32    v[14:15], v14 offset1:16
/*0000000002fc*/ v_add_f32       v6, v12, v6
/*000000000300*/ v_add_f32       v6, v13, v6
/*000000000304*/ s_waitcnt       lgkmcnt(0)
/*000000000308*/ v_mul_f32       v0, v14, v16
/*00000000030c*/ v_mul_f32       v4, v15, v17
/*000000000310*/ ds_read2_b32    v[14:15], v21 offset0:128 offset1:144
/*000000000318*/ ds_read2_b32    v[16:17], v10 offset0:128 offset1:144
/*000000000320*/ v_add_f32       v9, v0, v9
/*000000000324*/ v_add_f32       v9, v4, v9
/*000000000328*/ s_waitcnt       lgkmcnt(0)
/*00000000032c*/ v_mul_f32       v0, v14, v16
/*000000000330*/ v_add_f32       v0, v0, v6
/*000000000334*/ v_mul_f32       v6, v15, v17
/*000000000338*/ ds_read2_b32    v[14:15], v21 offset0:160 offset1:176
/*000000000340*/ ds_read2_b32    v[18:19], v10 offset0:160 offset1:176
/*000000000348*/ v_add_f32       v6, v6, v0
/*00000000034c*/ s_waitcnt       lgkmcnt(0)
/*000000000350*/ v_mul_f32       v4, v14, v18
/*000000000354*/ v_add_f32       v6, v4, v6
/*000000000358*/ v_mul_f32       v4, v15, v19
/*00000000035c*/ ds_read2_b32    v[14:15], v21 offset0:192 offset1:208
/*000000000364*/ ds_read2_b32    v[22:23], v10 offset0:192 offset1:208
/*00000000036c*/ v_add_f32       v0, v4, v6
/*000000000370*/ s_waitcnt       lgkmcnt(0)
/*000000000374*/ v_mul_f32       v6, v14, v22
/*000000000378*/ v_add_f32       v0, v6, v0
/*00000000037c*/ v_mul_f32       v6, v15, v23
/*000000000380*/ ds_read2_b32    v[14:15], v21 offset0:224 offset1:240
/*000000000388*/ ds_read2_b32    v[12:13], v10 offset0:224 offset1:240
/*000000000390*/ v_add_f32       v4, v6, v0
/*000000000394*/ s_waitcnt       lgkmcnt(0)
/*000000000398*/ v_mul_f32       v6, v14, v12
/*00000000039c*/ v_add_f32       v4, v6, v4
/*0000000003a0*/ v_mul_f32       v6, v15, v13
/*0000000003a4*/ v_add_f32       v4, v6, v4
/*0000000003a8*/ v_add_i32       v6, vcc, s28, v21
/*0000000003ac*/ ds_read2_b32    v[14:15], v6 offset1:16
/*0000000003b4*/ s_waitcnt       lgkmcnt(0)
/*0000000003b8*/ v_mul_f32       v6, v14, v16
/*0000000003bc*/ v_add_f32       v9, v6, v9
/*0000000003c0*/ v_mul_f32       v6, v15, v17
/*0000000003c4*/ v_add_f32       v9, v6, v9
/*0000000003c8*/ v_add_i32       v6, vcc, s24, v21
/*0000000003cc*/ ds_read2_b32    v[14:15], v6 offset1:16
/*0000000003d4*/ s_waitcnt       lgkmcnt(0)
/*0000000003d8*/ v_mul_f32       v18, v14, v18
/*0000000003dc*/ v_add_f32       v9, v18, v9
/*0000000003e0*/ v_mul_f32       v18, v15, v19
/*0000000003e4*/ v_add_f32       v9, v18, v9
/*0000000003e8*/ v_add_i32       v18, vcc, s4, v21
/*0000000003ec*/ ds_read2_b32    v[14:15], v18 offset1:16
/*0000000003f4*/ s_waitcnt       lgkmcnt(0)
/*0000000003f8*/ v_mul_f32       v6, v14, v22
/*0000000003fc*/ v_add_f32       v22, v6, v9
/*000000000400*/ v_mul_f32       v18, v15, v23
/*000000000404*/ v_add_f32       v22, v18, v22
/*000000000408*/ v_add_i32       v23, vcc, s5, v21
/*00000000040c*/ ds_read2_b32    v[14:15], v23 offset1:16
/*000000000414*/ s_and_b64       vcc, exec, s[18:19]
/*000000000418*/ s_waitcnt       lgkmcnt(0)
/*00000000041c*/ s_barrier
/*000000000420*/ v_mul_f32       v23, v14, v12
/*000000000424*/ v_add_f32       v22, v23, v22
/*000000000428*/ v_mul_f32       v23, v15, v13
/*00000000042c*/ v_add_f32       v0, v23, v22
/*000000000430*/ s_cbranch_vccnz .L1196_0
.L1076_0:
/*000000000434*/ s_and_saveexec_b64 s[18:19], s[12:13]
/*000000000438*/ s_cbranch_execz .L1136_0
/*00000000043c*/ v_mov_b32       v9, 0
/*000000000440*/ v_mov_b32       v6, v9
/*000000000444*/ v_lshl_b64      v[14:15], v[8:9], 2
/*00000000044c*/ v_lshl_b64      v[16:17], v[5:6], 2
/*000000000454*/ buffer_load_dword v22, v[14:15], s[20:23], 0 addr64
/*00000000045c*/ buffer_load_dword v23, v[16:17], s[20:23], 0 addr64
/*000000000464*/ s_waitcnt       vmcnt(0)
/*000000000468*/ ds_write2st64_b32 v7, v22, v23 offset1:4
.L1136_0:
/*000000000470*/ s_or_b64        exec, exec, s[18:19]
/*000000000474*/ s_and_saveexec_b64 s[10:11], s[14:15]
/*000000000478*/ s_cbranch_execz .L480_0
/*00000000047c*/ v_mov_b32       v12, 0
/*000000000480*/ v_lshl_b64      v[14:15], v[11:12], 2
/*000000000488*/ s_mov_b64       s[18:19], s[22:23]
/*00000000048c*/ buffer_load_dword v23, v[14:15], s[16:19], 0 addr64
/*000000000494*/ s_waitcnt       vmcnt(0)
/*000000000498*/ ds_write_b32    v20, v23
/*0000000004a0*/ s_branch        .L480_0
.L1188_0:
/*0000000004a4*/ s_cbranch_execnz .L1200_0
/*0000000004a8*/ s_branch        .L1216_0
.L1196_0:
/*0000000004ac*/ s_branch        .L1216_0
.L1200_0:
/*0000000004b0*/ s_lshr_b32      s0, s0, 1
/*0000000004b4*/ v_mov_b32       v0, 0
/*0000000004b8*/ v_add_i32       v3, vcc, s0, v2
/*0000000004bc*/ v_mov_b32       v4, v0
.L1216_0:
/*0000000004c0*/ v_mul_lo_u32    v5, v2, s2
/*0000000004c8*/ v_mul_lo_u32    v6, v3, s2
/*0000000004d0*/ s_lshl_b32      s10, s7, 4
/*0000000004d4*/ v_add_i32       v7, vcc, s10, v1
/*0000000004d8*/ v_add_i32       v8, vcc, v5, v7
/*0000000004dc*/ v_mov_b32       v9, 0
/*0000000004e0*/ v_lshl_b64      v[10:11], v[8:9], 2
/*0000000004e8*/ v_add_i32       v8, vcc, v6, v7
/*0000000004ec*/ s_mov_b32       s10, 0
/*0000000004f0*/ s_mov_b32       s11, 0xf000
/*0000000004f8*/ v_lshl_b64      v[12:13], v[8:9], 2
/*000000000500*/ buffer_store_dword v4, v[10:11], s[8:11], 0 addr64
/*000000000508*/ buffer_store_dword v0, v[12:13], s[8:11], 0 addr64
/*000000000510*/ s_endpgm
