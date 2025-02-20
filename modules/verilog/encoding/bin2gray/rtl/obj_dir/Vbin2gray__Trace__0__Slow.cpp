// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vbin2gray__Syms.h"


VL_ATTR_COLD void Vbin2gray___024root__trace_init_sub__TOP__0(Vbin2gray___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root__trace_init_sub__TOP__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    const int c = vlSymsp->__Vm_baseCode;
    // Body
    tracep->pushPrefix("bin2gray_tb", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+6,0,"DATA_BITS",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+7,0,"N_TESTS",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->pushPrefix("TESTS_IN", VerilatedTracePrefixType::ARRAY_UNPACKED);
    for (int i = 0; i < 16; ++i) {
        tracep->declBus(c+8+i*1,0,"",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, true,(i+0), 7,0);
    }
    tracep->popPrefix();
    tracep->declBus(c+1,0,"b_data_in",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->declBus(c+2,0,"g_data_in",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->declBus(c+2,0,"g_data_out",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->declBus(c+3,0,"b_data_out",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->declBit(c+4,0,"clk",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("bin2gray_inst", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+6,0,"N",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+1,0,"bin_in",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->declBus(c+2,0,"gray_out",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->popPrefix();
    tracep->pushPrefix("gray2bin_inst", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+6,0,"N",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+2,0,"gray_in",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->declBus(c+3,0,"bin_out",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->popPrefix();
    tracep->pushPrefix("unnamedblk1", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+5,0,"test_idx",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::INTEGER, false,-1, 31,0);
    tracep->popPrefix();
    tracep->popPrefix();
}

VL_ATTR_COLD void Vbin2gray___024root__trace_init_top(Vbin2gray___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root__trace_init_top\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vbin2gray___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void Vbin2gray___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
VL_ATTR_COLD void Vbin2gray___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vbin2gray___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vbin2gray___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/);

VL_ATTR_COLD void Vbin2gray___024root__trace_register(Vbin2gray___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root__trace_register\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    tracep->addConstCb(&Vbin2gray___024root__trace_const_0, 0U, vlSelf);
    tracep->addFullCb(&Vbin2gray___024root__trace_full_0, 0U, vlSelf);
    tracep->addChgCb(&Vbin2gray___024root__trace_chg_0, 0U, vlSelf);
    tracep->addCleanupCb(&Vbin2gray___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void Vbin2gray___024root__trace_const_0_sub_0(Vbin2gray___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vbin2gray___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root__trace_const_0\n"); );
    // Init
    Vbin2gray___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vbin2gray___024root*>(voidSelf);
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    Vbin2gray___024root__trace_const_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vbin2gray___024root__trace_const_0_sub_0(Vbin2gray___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root__trace_const_0_sub_0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullIData(oldp+6,(8U),32);
    bufp->fullIData(oldp+7,(0x10U),32);
    bufp->fullCData(oldp+8,(vlSelfRef.bin2gray_tb__DOT__TESTS_IN[0]),8);
    bufp->fullCData(oldp+9,(vlSelfRef.bin2gray_tb__DOT__TESTS_IN[1]),8);
    bufp->fullCData(oldp+10,(vlSelfRef.bin2gray_tb__DOT__TESTS_IN[2]),8);
    bufp->fullCData(oldp+11,(vlSelfRef.bin2gray_tb__DOT__TESTS_IN[3]),8);
    bufp->fullCData(oldp+12,(vlSelfRef.bin2gray_tb__DOT__TESTS_IN[4]),8);
    bufp->fullCData(oldp+13,(vlSelfRef.bin2gray_tb__DOT__TESTS_IN[5]),8);
    bufp->fullCData(oldp+14,(vlSelfRef.bin2gray_tb__DOT__TESTS_IN[6]),8);
    bufp->fullCData(oldp+15,(vlSelfRef.bin2gray_tb__DOT__TESTS_IN[7]),8);
    bufp->fullCData(oldp+16,(vlSelfRef.bin2gray_tb__DOT__TESTS_IN[8]),8);
    bufp->fullCData(oldp+17,(vlSelfRef.bin2gray_tb__DOT__TESTS_IN[9]),8);
    bufp->fullCData(oldp+18,(vlSelfRef.bin2gray_tb__DOT__TESTS_IN[10]),8);
    bufp->fullCData(oldp+19,(vlSelfRef.bin2gray_tb__DOT__TESTS_IN[11]),8);
    bufp->fullCData(oldp+20,(vlSelfRef.bin2gray_tb__DOT__TESTS_IN[12]),8);
    bufp->fullCData(oldp+21,(vlSelfRef.bin2gray_tb__DOT__TESTS_IN[13]),8);
    bufp->fullCData(oldp+22,(vlSelfRef.bin2gray_tb__DOT__TESTS_IN[14]),8);
    bufp->fullCData(oldp+23,(vlSelfRef.bin2gray_tb__DOT__TESTS_IN[15]),8);
}

VL_ATTR_COLD void Vbin2gray___024root__trace_full_0_sub_0(Vbin2gray___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vbin2gray___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root__trace_full_0\n"); );
    // Init
    Vbin2gray___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vbin2gray___024root*>(voidSelf);
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    Vbin2gray___024root__trace_full_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vbin2gray___024root__trace_full_0_sub_0(Vbin2gray___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root__trace_full_0_sub_0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullCData(oldp+1,(vlSelfRef.bin2gray_tb__DOT__b_data_in),8);
    bufp->fullCData(oldp+2,(vlSelfRef.bin2gray_tb__DOT__g_data_in),8);
    bufp->fullCData(oldp+3,(vlSelfRef.bin2gray_tb__DOT__b_data_out),8);
    bufp->fullBit(oldp+4,(vlSelfRef.bin2gray_tb__DOT__clk));
    bufp->fullIData(oldp+5,(vlSelfRef.bin2gray_tb__DOT__unnamedblk1__DOT__test_idx),32);
}
