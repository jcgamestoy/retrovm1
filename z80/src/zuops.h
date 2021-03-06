/*
Copyright (c) 2013 Juan Carlos González Amestoy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

//Autogenerated by src/z80uops.lua don't touch.


#include "z80.h"


void z80PrefixOpdd(z80 *z);
void z80PrefixOpfd(z80 *z);
void z80PrefixOped(z80 *z);
void z80PrefixOpcb(z80 *z);
void z80Con1_pc_2(z80 *z);
void z80ReadInc_pc_tm1_1(z80 *z);
void z80Prefix2Opddcb(z80 *z);
void z80Prefix2Opfdcb(z80 *z);
void z80Con1_hl_2(z80 *z);
void z80Write_hl_tm1_1(z80 *z);
void z80ReadInc_pc_b_1(z80 *z);
void z80Read_hl_b_1(z80 *z);
void z80Con2_pc_1(z80 *z);
void z80Con1i_ix_2(z80 *z);
void z80ReadI_ix_b_1(z80 *z);
void z80Con1i_iy_2(z80 *z);
void z80ReadI_iy_b_1(z80 *z);
void z80Write_hl_b_1(z80 *z);
void z80Con1i_b_2(z80 *z);
void z80WriteI_ix_b_1(z80 *z);
void z80WriteI_iy_b_1(z80 *z);
void z80ReadInc_pc_c_1(z80 *z);
void z80Read_hl_c_1(z80 *z);
void z80ReadI_ix_c_1(z80 *z);
void z80ReadI_iy_c_1(z80 *z);
void z80Write_hl_c_1(z80 *z);
void z80Con1i_c_2(z80 *z);
void z80WriteI_ix_c_1(z80 *z);
void z80WriteI_iy_c_1(z80 *z);
void z80ReadInc_pc_d_1(z80 *z);
void z80Read_hl_d_1(z80 *z);
void z80ReadI_ix_d_1(z80 *z);
void z80ReadI_iy_d_1(z80 *z);
void z80Write_hl_d_1(z80 *z);
void z80Con1i_d_2(z80 *z);
void z80WriteI_ix_d_1(z80 *z);
void z80WriteI_iy_d_1(z80 *z);
void z80ReadInc_pc_e_1(z80 *z);
void z80Read_hl_e_1(z80 *z);
void z80ReadI_ix_e_1(z80 *z);
void z80ReadI_iy_e_1(z80 *z);
void z80Write_hl_e_1(z80 *z);
void z80Con1i_e_2(z80 *z);
void z80WriteI_ix_e_1(z80 *z);
void z80WriteI_iy_e_1(z80 *z);
void z80ReadInc_pc_h_1(z80 *z);
void z80Read_hl_h_1(z80 *z);
void z80ReadI_ix_h_1(z80 *z);
void z80ReadI_iy_h_1(z80 *z);
void z80Write_hl_h_1(z80 *z);
void z80Con1i_h_2(z80 *z);
void z80WriteI_ix_h_1(z80 *z);
void z80WriteI_iy_h_1(z80 *z);
void z80ReadInc_pc_ixh_1(z80 *z);
void z80ReadInc_pc_iyh_1(z80 *z);
void z80ReadInc_pc_l_1(z80 *z);
void z80Read_hl_l_1(z80 *z);
void z80ReadI_ix_l_1(z80 *z);
void z80ReadI_iy_l_1(z80 *z);
void z80Write_hl_l_1(z80 *z);
void z80Con1i_l_2(z80 *z);
void z80WriteI_ix_l_1(z80 *z);
void z80WriteI_iy_l_1(z80 *z);
void z80ReadInc_pc_ixl_1(z80 *z);
void z80ReadInc_pc_iyl_1(z80 *z);
void z80ReadInc_pc_a_1(z80 *z);
void z80Read_hl_a_1(z80 *z);
void z80ReadI_ix_a_1(z80 *z);
void z80ReadI_iy_a_1(z80 *z);
void z80Write_hl_a_1(z80 *z);
void z80Con1i_a_2(z80 *z);
void z80WriteI_ix_a_1(z80 *z);
void z80WriteI_iy_a_1(z80 *z);
void z80ReadInc_pc_tm2_1(z80 *z);
void z80WriteI_ix_tm2_1(z80 *z);
void z80WriteI_iy_tm2_1(z80 *z);
void z80Con1_bc_2(z80 *z);
void z80Read_mptr_a_1(z80 *z);
void z80Con1_de_2(z80 *z);
void z80stoi_bc_aOp(z80 *z);
void z80stoi_de_aOp(z80 *z);
void z80ReadInc_pc_mptrl_1(z80 *z);
void z80ReadInc_pc_mptrh_1(z80 *z);
void z80Con1_mptr_2(z80 *z);
void z80ReadInc_mptr_a_1(z80 *z);
void stamemOp(z80 *z);
void z80Con2_ir_1(z80 *z);
void z80Con2_tm_1(z80 *z);
void z80ReadInc_pc_spl_1(z80 *z);
void z80ReadInc_pc_sph_1(z80 *z);
void z80ReadInc_mptr_l_1(z80 *z);
void z80Read_mptr_h_1(z80 *z);
void z80ReadInc_mptr_c_1(z80 *z);
void z80Read_mptr_b_1(z80 *z);
void z80ReadInc_mptr_e_1(z80 *z);
void z80Read_mptr_d_1(z80 *z);
void z80ReadInc_mptr_spl_1(z80 *z);
void z80Read_mptr_sph_1(z80 *z);
void z80ReadInc_mptr_ixl_1(z80 *z);
void z80Read_mptr_ixh_1(z80 *z);
void z80ReadInc_mptr_iyl_1(z80 *z);
void z80Read_mptr_iyh_1(z80 *z);
void z80WriteInc_mptr_l_1(z80 *z);
void z80Write_mptr_h_1(z80 *z);
void z80WriteInc_mptr_c_1(z80 *z);
void z80Write_mptr_b_1(z80 *z);
void z80WriteInc_mptr_e_1(z80 *z);
void z80Write_mptr_d_1(z80 *z);
void z80WriteInc_mptr_spl_1(z80 *z);
void z80Write_mptr_sph_1(z80 *z);
void z80WriteInc_mptr_ixl_1(z80 *z);
void z80Write_mptr_ixh_1(z80 *z);
void z80WriteInc_mptr_iyl_1(z80 *z);
void z80Write_mptr_iyh_1(z80 *z);
void z80ConDec1_sp_2(z80 *z);
void z80WriteDec_sp_b_1(z80 *z);
void z80WriteDec_sp_c_1(z80 *z);
void z80WriteDec_sp_d_1(z80 *z);
void z80WriteDec_sp_e_1(z80 *z);
void z80WriteDec_sp_h_1(z80 *z);
void z80WriteDec_sp_l_1(z80 *z);
void z80WriteDec_sp_a_1(z80 *z);
void z80WriteDec_sp_f_1(z80 *z);
void z80WriteDec_sp_ixh_1(z80 *z);
void z80WriteDec_sp_ixl_1(z80 *z);
void z80WriteDec_sp_iyh_1(z80 *z);
void z80WriteDec_sp_iyl_1(z80 *z);
void z80Con1_sp_2(z80 *z);
void z80ReadInc_sp_c_1(z80 *z);
void z80ReadInc_sp_b_1(z80 *z);
void z80ReadInc_sp_e_1(z80 *z);
void z80ReadInc_sp_d_1(z80 *z);
void z80ReadInc_sp_l_1(z80 *z);
void z80ReadInc_sp_h_1(z80 *z);
void z80ReadInc_sp_f_1(z80 *z);
void z80ReadInc_sp_a_1(z80 *z);
void z80ReadInc_sp_ixl_1(z80 *z);
void z80ReadInc_sp_ixh_1(z80 *z);
void z80ReadInc_sp_iyl_1(z80 *z);
void z80ReadInc_sp_iyh_1(z80 *z);
void z80ReadInc_sp_mptrl_1(z80 *z);
void z80Read_sp_mptrh_1(z80 *z);
void z80Con2_sp_1(z80 *z);
void z80Write_sp_h_1(z80 *z);
void exsphlOp(z80 *z);
void z80Write_sp_ixh_1(z80 *z);
void exspixOp(z80 *z);
void z80Write_sp_iyh_1(z80 *z);
void exspiyOp(z80 *z);
void z80Read_hl_tm1_1(z80 *z);
void z80Write_de_tm1_1(z80 *z);
void z80Con2_de_1(z80 *z);
void ldiOp(z80 *z);
void lddOp(z80 *z);
void z80Con1_aux_2(z80 *z);
void z80Write_aux_tm1_1(z80 *z);
void z80Con2_aux_1(z80 *z);
void ldirOp(z80 *z);
void lddrOp(z80 *z);
void z80Con2_hl_1(z80 *z);
void cpiOp(z80 *z);
void cpdOp(z80 *z);
void z80Read_aux_tm1_1(z80 *z);
void cpirOp(z80 *z);
void cpdrOp(z80 *z);
void add8_nnOp(z80 *z);
void add8_hlOp(z80 *z);
void add8_ixOp(z80 *z);
void add8_iyOp(z80 *z);
void adc8_nnOp(z80 *z);
void adc8_hlOp(z80 *z);
void adc8_ixOp(z80 *z);
void adc8_iyOp(z80 *z);
void sub8_nnOp(z80 *z);
void sub8_hlOp(z80 *z);
void sub8_ixOp(z80 *z);
void sub8_iyOp(z80 *z);
void sbc8_nnOp(z80 *z);
void sbc8_hlOp(z80 *z);
void sbc8_ixOp(z80 *z);
void sbc8_iyOp(z80 *z);
void and8_nnOp(z80 *z);
void and8_hlOp(z80 *z);
void and8_ixOp(z80 *z);
void and8_iyOp(z80 *z);
void or8_nnOp(z80 *z);
void or8_hlOp(z80 *z);
void or8_ixOp(z80 *z);
void or8_iyOp(z80 *z);
void xor8_nnOp(z80 *z);
void xor8_hlOp(z80 *z);
void xor8_ixOp(z80 *z);
void xor8_iyOp(z80 *z);
void cp8_nnOp(z80 *z);
void cp8_hlOp(z80 *z);
void cp8_ixOp(z80 *z);
void cp8_iyOp(z80 *z);
void z80Read_hl_tm2_1(z80 *z);
void inc8_hlOp(z80 *z);
void z80Write_hl_tm2_1(z80 *z);
void z80ReadI_ix_tm2_1(z80 *z);
void inc8_ixOp(z80 *z);
void z80Write_mptr_tm2_1(z80 *z);
void z80ReadI_iy_tm2_1(z80 *z);
void inc8_iyOp(z80 *z);
void dec8_hlOp(z80 *z);
void dec8_ixOp(z80 *z);
void dec8_iyOp(z80 *z);
void eiOp(z80 *z);
void bit_0_hlOp(z80 *z);
void bit_0_ixOp(z80 *z);
void bit_0_iyOp(z80 *z);
void res_0_hlOp(z80 *z);
void res_0_ixOp(z80 *z);
void res_0_iyOp(z80 *z);
void set_0_hlOp(z80 *z);
void set_0_ixOp(z80 *z);
void set_0_iyOp(z80 *z);
void bit_1_hlOp(z80 *z);
void bit_1_ixOp(z80 *z);
void bit_1_iyOp(z80 *z);
void res_1_hlOp(z80 *z);
void res_1_ixOp(z80 *z);
void res_1_iyOp(z80 *z);
void set_1_hlOp(z80 *z);
void set_1_ixOp(z80 *z);
void set_1_iyOp(z80 *z);
void bit_2_hlOp(z80 *z);
void bit_2_ixOp(z80 *z);
void bit_2_iyOp(z80 *z);
void res_2_hlOp(z80 *z);
void res_2_ixOp(z80 *z);
void res_2_iyOp(z80 *z);
void set_2_hlOp(z80 *z);
void set_2_ixOp(z80 *z);
void set_2_iyOp(z80 *z);
void bit_3_hlOp(z80 *z);
void bit_3_ixOp(z80 *z);
void bit_3_iyOp(z80 *z);
void res_3_hlOp(z80 *z);
void res_3_ixOp(z80 *z);
void res_3_iyOp(z80 *z);
void set_3_hlOp(z80 *z);
void set_3_ixOp(z80 *z);
void set_3_iyOp(z80 *z);
void bit_4_hlOp(z80 *z);
void bit_4_ixOp(z80 *z);
void bit_4_iyOp(z80 *z);
void res_4_hlOp(z80 *z);
void res_4_ixOp(z80 *z);
void res_4_iyOp(z80 *z);
void set_4_hlOp(z80 *z);
void set_4_ixOp(z80 *z);
void set_4_iyOp(z80 *z);
void bit_5_hlOp(z80 *z);
void bit_5_ixOp(z80 *z);
void bit_5_iyOp(z80 *z);
void res_5_hlOp(z80 *z);
void res_5_ixOp(z80 *z);
void res_5_iyOp(z80 *z);
void set_5_hlOp(z80 *z);
void set_5_ixOp(z80 *z);
void set_5_iyOp(z80 *z);
void bit_6_hlOp(z80 *z);
void bit_6_ixOp(z80 *z);
void bit_6_iyOp(z80 *z);
void res_6_hlOp(z80 *z);
void res_6_ixOp(z80 *z);
void res_6_iyOp(z80 *z);
void set_6_hlOp(z80 *z);
void set_6_ixOp(z80 *z);
void set_6_iyOp(z80 *z);
void bit_7_hlOp(z80 *z);
void bit_7_ixOp(z80 *z);
void bit_7_iyOp(z80 *z);
void res_7_hlOp(z80 *z);
void res_7_ixOp(z80 *z);
void res_7_iyOp(z80 *z);
void set_7_hlOp(z80 *z);
void set_7_ixOp(z80 *z);
void set_7_iyOp(z80 *z);
void rlc_ixbOp(z80 *z);
void rlc_iybOp(z80 *z);
void rl_ixbOp(z80 *z);
void rl_iybOp(z80 *z);
void rrc_ixbOp(z80 *z);
void rrc_iybOp(z80 *z);
void rr_ixbOp(z80 *z);
void rr_iybOp(z80 *z);
void sla_ixbOp(z80 *z);
void sla_iybOp(z80 *z);
void sll_ixbOp(z80 *z);
void sll_iybOp(z80 *z);
void sra_ixbOp(z80 *z);
void sra_iybOp(z80 *z);
void srl_ixbOp(z80 *z);
void srl_iybOp(z80 *z);
void res_0_ixbOp(z80 *z);
void res_0_iybOp(z80 *z);
void set_0_ixbOp(z80 *z);
void set_0_iybOp(z80 *z);
void res_1_ixbOp(z80 *z);
void res_1_iybOp(z80 *z);
void set_1_ixbOp(z80 *z);
void set_1_iybOp(z80 *z);
void res_2_ixbOp(z80 *z);
void res_2_iybOp(z80 *z);
void set_2_ixbOp(z80 *z);
void set_2_iybOp(z80 *z);
void res_3_ixbOp(z80 *z);
void res_3_iybOp(z80 *z);
void set_3_ixbOp(z80 *z);
void set_3_iybOp(z80 *z);
void res_4_ixbOp(z80 *z);
void res_4_iybOp(z80 *z);
void set_4_ixbOp(z80 *z);
void set_4_iybOp(z80 *z);
void res_5_ixbOp(z80 *z);
void res_5_iybOp(z80 *z);
void set_5_ixbOp(z80 *z);
void set_5_iybOp(z80 *z);
void res_6_ixbOp(z80 *z);
void res_6_iybOp(z80 *z);
void set_6_ixbOp(z80 *z);
void set_6_iybOp(z80 *z);
void res_7_ixbOp(z80 *z);
void res_7_iybOp(z80 *z);
void set_7_ixbOp(z80 *z);
void set_7_iybOp(z80 *z);
void rlc_ixcOp(z80 *z);
void rlc_iycOp(z80 *z);
void rl_ixcOp(z80 *z);
void rl_iycOp(z80 *z);
void rrc_ixcOp(z80 *z);
void rrc_iycOp(z80 *z);
void rr_ixcOp(z80 *z);
void rr_iycOp(z80 *z);
void sla_ixcOp(z80 *z);
void sla_iycOp(z80 *z);
void sll_ixcOp(z80 *z);
void sll_iycOp(z80 *z);
void sra_ixcOp(z80 *z);
void sra_iycOp(z80 *z);
void srl_ixcOp(z80 *z);
void srl_iycOp(z80 *z);
void res_0_ixcOp(z80 *z);
void res_0_iycOp(z80 *z);
void set_0_ixcOp(z80 *z);
void set_0_iycOp(z80 *z);
void res_1_ixcOp(z80 *z);
void res_1_iycOp(z80 *z);
void set_1_ixcOp(z80 *z);
void set_1_iycOp(z80 *z);
void res_2_ixcOp(z80 *z);
void res_2_iycOp(z80 *z);
void set_2_ixcOp(z80 *z);
void set_2_iycOp(z80 *z);
void res_3_ixcOp(z80 *z);
void res_3_iycOp(z80 *z);
void set_3_ixcOp(z80 *z);
void set_3_iycOp(z80 *z);
void res_4_ixcOp(z80 *z);
void res_4_iycOp(z80 *z);
void set_4_ixcOp(z80 *z);
void set_4_iycOp(z80 *z);
void res_5_ixcOp(z80 *z);
void res_5_iycOp(z80 *z);
void set_5_ixcOp(z80 *z);
void set_5_iycOp(z80 *z);
void res_6_ixcOp(z80 *z);
void res_6_iycOp(z80 *z);
void set_6_ixcOp(z80 *z);
void set_6_iycOp(z80 *z);
void res_7_ixcOp(z80 *z);
void res_7_iycOp(z80 *z);
void set_7_ixcOp(z80 *z);
void set_7_iycOp(z80 *z);
void rlc_ixdOp(z80 *z);
void rlc_iydOp(z80 *z);
void rl_ixdOp(z80 *z);
void rl_iydOp(z80 *z);
void rrc_ixdOp(z80 *z);
void rrc_iydOp(z80 *z);
void rr_ixdOp(z80 *z);
void rr_iydOp(z80 *z);
void sla_ixdOp(z80 *z);
void sla_iydOp(z80 *z);
void sll_ixdOp(z80 *z);
void sll_iydOp(z80 *z);
void sra_ixdOp(z80 *z);
void sra_iydOp(z80 *z);
void srl_ixdOp(z80 *z);
void srl_iydOp(z80 *z);
void res_0_ixdOp(z80 *z);
void res_0_iydOp(z80 *z);
void set_0_ixdOp(z80 *z);
void set_0_iydOp(z80 *z);
void res_1_ixdOp(z80 *z);
void res_1_iydOp(z80 *z);
void set_1_ixdOp(z80 *z);
void set_1_iydOp(z80 *z);
void res_2_ixdOp(z80 *z);
void res_2_iydOp(z80 *z);
void set_2_ixdOp(z80 *z);
void set_2_iydOp(z80 *z);
void res_3_ixdOp(z80 *z);
void res_3_iydOp(z80 *z);
void set_3_ixdOp(z80 *z);
void set_3_iydOp(z80 *z);
void res_4_ixdOp(z80 *z);
void res_4_iydOp(z80 *z);
void set_4_ixdOp(z80 *z);
void set_4_iydOp(z80 *z);
void res_5_ixdOp(z80 *z);
void res_5_iydOp(z80 *z);
void set_5_ixdOp(z80 *z);
void set_5_iydOp(z80 *z);
void res_6_ixdOp(z80 *z);
void res_6_iydOp(z80 *z);
void set_6_ixdOp(z80 *z);
void set_6_iydOp(z80 *z);
void res_7_ixdOp(z80 *z);
void res_7_iydOp(z80 *z);
void set_7_ixdOp(z80 *z);
void set_7_iydOp(z80 *z);
void rlc_ixeOp(z80 *z);
void rlc_iyeOp(z80 *z);
void rl_ixeOp(z80 *z);
void rl_iyeOp(z80 *z);
void rrc_ixeOp(z80 *z);
void rrc_iyeOp(z80 *z);
void rr_ixeOp(z80 *z);
void rr_iyeOp(z80 *z);
void sla_ixeOp(z80 *z);
void sla_iyeOp(z80 *z);
void sll_ixeOp(z80 *z);
void sll_iyeOp(z80 *z);
void sra_ixeOp(z80 *z);
void sra_iyeOp(z80 *z);
void srl_ixeOp(z80 *z);
void srl_iyeOp(z80 *z);
void res_0_ixeOp(z80 *z);
void res_0_iyeOp(z80 *z);
void set_0_ixeOp(z80 *z);
void set_0_iyeOp(z80 *z);
void res_1_ixeOp(z80 *z);
void res_1_iyeOp(z80 *z);
void set_1_ixeOp(z80 *z);
void set_1_iyeOp(z80 *z);
void res_2_ixeOp(z80 *z);
void res_2_iyeOp(z80 *z);
void set_2_ixeOp(z80 *z);
void set_2_iyeOp(z80 *z);
void res_3_ixeOp(z80 *z);
void res_3_iyeOp(z80 *z);
void set_3_ixeOp(z80 *z);
void set_3_iyeOp(z80 *z);
void res_4_ixeOp(z80 *z);
void res_4_iyeOp(z80 *z);
void set_4_ixeOp(z80 *z);
void set_4_iyeOp(z80 *z);
void res_5_ixeOp(z80 *z);
void res_5_iyeOp(z80 *z);
void set_5_ixeOp(z80 *z);
void set_5_iyeOp(z80 *z);
void res_6_ixeOp(z80 *z);
void res_6_iyeOp(z80 *z);
void set_6_ixeOp(z80 *z);
void set_6_iyeOp(z80 *z);
void res_7_ixeOp(z80 *z);
void res_7_iyeOp(z80 *z);
void set_7_ixeOp(z80 *z);
void set_7_iyeOp(z80 *z);
void rlc_ixhOp(z80 *z);
void rlc_iyhOp(z80 *z);
void rl_ixhOp(z80 *z);
void rl_iyhOp(z80 *z);
void rrc_ixhOp(z80 *z);
void rrc_iyhOp(z80 *z);
void rr_ixhOp(z80 *z);
void rr_iyhOp(z80 *z);
void sla_ixhOp(z80 *z);
void sla_iyhOp(z80 *z);
void sll_ixhOp(z80 *z);
void sll_iyhOp(z80 *z);
void sra_ixhOp(z80 *z);
void sra_iyhOp(z80 *z);
void srl_ixhOp(z80 *z);
void srl_iyhOp(z80 *z);
void res_0_ixhOp(z80 *z);
void res_0_iyhOp(z80 *z);
void set_0_ixhOp(z80 *z);
void set_0_iyhOp(z80 *z);
void res_1_ixhOp(z80 *z);
void res_1_iyhOp(z80 *z);
void set_1_ixhOp(z80 *z);
void set_1_iyhOp(z80 *z);
void res_2_ixhOp(z80 *z);
void res_2_iyhOp(z80 *z);
void set_2_ixhOp(z80 *z);
void set_2_iyhOp(z80 *z);
void res_3_ixhOp(z80 *z);
void res_3_iyhOp(z80 *z);
void set_3_ixhOp(z80 *z);
void set_3_iyhOp(z80 *z);
void res_4_ixhOp(z80 *z);
void res_4_iyhOp(z80 *z);
void set_4_ixhOp(z80 *z);
void set_4_iyhOp(z80 *z);
void res_5_ixhOp(z80 *z);
void res_5_iyhOp(z80 *z);
void set_5_ixhOp(z80 *z);
void set_5_iyhOp(z80 *z);
void res_6_ixhOp(z80 *z);
void res_6_iyhOp(z80 *z);
void set_6_ixhOp(z80 *z);
void set_6_iyhOp(z80 *z);
void res_7_ixhOp(z80 *z);
void res_7_iyhOp(z80 *z);
void set_7_ixhOp(z80 *z);
void set_7_iyhOp(z80 *z);
void rlc_ixlOp(z80 *z);
void rlc_iylOp(z80 *z);
void rl_ixlOp(z80 *z);
void rl_iylOp(z80 *z);
void rrc_ixlOp(z80 *z);
void rrc_iylOp(z80 *z);
void rr_ixlOp(z80 *z);
void rr_iylOp(z80 *z);
void sla_ixlOp(z80 *z);
void sla_iylOp(z80 *z);
void sll_ixlOp(z80 *z);
void sll_iylOp(z80 *z);
void sra_ixlOp(z80 *z);
void sra_iylOp(z80 *z);
void srl_ixlOp(z80 *z);
void srl_iylOp(z80 *z);
void res_0_ixlOp(z80 *z);
void res_0_iylOp(z80 *z);
void set_0_ixlOp(z80 *z);
void set_0_iylOp(z80 *z);
void res_1_ixlOp(z80 *z);
void res_1_iylOp(z80 *z);
void set_1_ixlOp(z80 *z);
void set_1_iylOp(z80 *z);
void res_2_ixlOp(z80 *z);
void res_2_iylOp(z80 *z);
void set_2_ixlOp(z80 *z);
void set_2_iylOp(z80 *z);
void res_3_ixlOp(z80 *z);
void res_3_iylOp(z80 *z);
void set_3_ixlOp(z80 *z);
void set_3_iylOp(z80 *z);
void res_4_ixlOp(z80 *z);
void res_4_iylOp(z80 *z);
void set_4_ixlOp(z80 *z);
void set_4_iylOp(z80 *z);
void res_5_ixlOp(z80 *z);
void res_5_iylOp(z80 *z);
void set_5_ixlOp(z80 *z);
void set_5_iylOp(z80 *z);
void res_6_ixlOp(z80 *z);
void res_6_iylOp(z80 *z);
void set_6_ixlOp(z80 *z);
void set_6_iylOp(z80 *z);
void res_7_ixlOp(z80 *z);
void res_7_iylOp(z80 *z);
void set_7_ixlOp(z80 *z);
void set_7_iylOp(z80 *z);
void rlc_ixaOp(z80 *z);
void rlc_iyaOp(z80 *z);
void rl_ixaOp(z80 *z);
void rl_iyaOp(z80 *z);
void rrc_ixaOp(z80 *z);
void rrc_iyaOp(z80 *z);
void rr_ixaOp(z80 *z);
void rr_iyaOp(z80 *z);
void sla_ixaOp(z80 *z);
void sla_iyaOp(z80 *z);
void sll_ixaOp(z80 *z);
void sll_iyaOp(z80 *z);
void sra_ixaOp(z80 *z);
void sra_iyaOp(z80 *z);
void srl_ixaOp(z80 *z);
void srl_iyaOp(z80 *z);
void res_0_ixaOp(z80 *z);
void res_0_iyaOp(z80 *z);
void set_0_ixaOp(z80 *z);
void set_0_iyaOp(z80 *z);
void res_1_ixaOp(z80 *z);
void res_1_iyaOp(z80 *z);
void set_1_ixaOp(z80 *z);
void set_1_iyaOp(z80 *z);
void res_2_ixaOp(z80 *z);
void res_2_iyaOp(z80 *z);
void set_2_ixaOp(z80 *z);
void set_2_iyaOp(z80 *z);
void res_3_ixaOp(z80 *z);
void res_3_iyaOp(z80 *z);
void set_3_ixaOp(z80 *z);
void set_3_iyaOp(z80 *z);
void res_4_ixaOp(z80 *z);
void res_4_iyaOp(z80 *z);
void set_4_ixaOp(z80 *z);
void set_4_iyaOp(z80 *z);
void res_5_ixaOp(z80 *z);
void res_5_iyaOp(z80 *z);
void set_5_ixaOp(z80 *z);
void set_5_iyaOp(z80 *z);
void res_6_ixaOp(z80 *z);
void res_6_iyaOp(z80 *z);
void set_6_ixaOp(z80 *z);
void set_6_iyaOp(z80 *z);
void res_7_ixaOp(z80 *z);
void res_7_iyaOp(z80 *z);
void set_7_ixaOp(z80 *z);
void set_7_iyaOp(z80 *z);
void rlc_hlOp(z80 *z);
void rlc_ixOp(z80 *z);
void rlc_iyOp(z80 *z);
void rl_hlOp(z80 *z);
void rl_ixOp(z80 *z);
void rl_iyOp(z80 *z);
void rrc_hlOp(z80 *z);
void rrc_ixOp(z80 *z);
void rrc_iyOp(z80 *z);
void rr_hlOp(z80 *z);
void rr_ixOp(z80 *z);
void rr_iyOp(z80 *z);
void sla_hlOp(z80 *z);
void sla_ixOp(z80 *z);
void sla_iyOp(z80 *z);
void sll_hlOp(z80 *z);
void sll_ixOp(z80 *z);
void sll_iyOp(z80 *z);
void sra_hlOp(z80 *z);
void sra_ixOp(z80 *z);
void sra_iyOp(z80 *z);
void srl_hlOp(z80 *z);
void srl_ixOp(z80 *z);
void srl_iyOp(z80 *z);
void rldOp(z80 *z);
void rrdOp(z80 *z);
void rettOp(z80 *z);
void callccOp(z80 *z);
void z80Con1_pc_1(z80 *z);
void jmpnzOp(z80 *z);
void jmpzOp(z80 *z);
void jmpncOp(z80 *z);
void jmpcOp(z80 *z);
void jmppoOp(z80 *z);
void jmppeOp(z80 *z);
void jmppOp(z80 *z);
void jmpmOp(z80 *z);
void jrOp(z80 *z);
void jrnzOp(z80 *z);
void jrzOp(z80 *z);
void jrncOp(z80 *z);
void jrcOp(z80 *z);
void djnzOp(z80 *z);
void callOp(z80 *z);
void z80WriteDec_sp_tm2_1(z80 *z);
void z80WriteDec_sp_tm1_1(z80 *z);
void callnzOp(z80 *z);
void callzOp(z80 *z);
void callncOp(z80 *z);
void callcOp(z80 *z);
void callpoOp(z80 *z);
void callpeOp(z80 *z);
void callpOp(z80 *z);
void callmOp(z80 *z);
void z80ReadInc_sp_pcl_1(z80 *z);
void in_aOp(z80 *z);
void z80In_tm_a_2(z80 *z);
void z80ConIO_bc_2(z80 *z);
void inrbOp(z80 *z);
void inrcOp(z80 *z);
void inrdOp(z80 *z);
void inreOp(z80 *z);
void inrhOp(z80 *z);
void inrlOp(z80 *z);
void inraOp(z80 *z);
void inrtm1Op(z80 *z);
void z80In_bc_tm1_2(z80 *z);
void z80Con1_hl_1(z80 *z);
void iniOp(z80 *z);
void z80WriteInc_hl_tm1_1(z80 *z);
void inirOp(z80 *z);
void indOp(z80 *z);
void indrOp(z80 *z);
void outaOp(z80 *z);
void z80ConIO_tm_2(z80 *z);
void z80Out_tm_a_2(z80 *z);
void z80Out_bc_tm1_2(z80 *z);
void z80Out_bc_b_2(z80 *z);
void z80Out_bc_c_2(z80 *z);
void z80Out_bc_d_2(z80 *z);
void z80Out_bc_e_2(z80 *z);
void z80Out_bc_h_2(z80 *z);
void z80Out_bc_l_2(z80 *z);
void z80Out_bc_a_2(z80 *z);
void z80ReadInc_hl_tm1_1(z80 *z);
void outiOp(z80 *z);
void otirOp(z80 *z);
void outdOp(z80 *z);
void otdrOp(z80 *z);
void z80_i0Op(z80 *z);
void z80_i1Op(z80 *z);
void z80WriteDec_sp_pch_1(z80 *z);
void z80WriteDec_sp_pcl_1(z80 *z);
void z80Con1_tm_2(z80 *z);
void z80ReadInc_tm_pcl_1(z80 *z);
void z80_i2Op(z80 *z);
