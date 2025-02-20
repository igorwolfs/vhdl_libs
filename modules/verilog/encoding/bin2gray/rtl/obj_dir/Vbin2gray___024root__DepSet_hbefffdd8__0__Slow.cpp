// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vbin2gray.h for the primary calling header

#include "Vbin2gray__pch.h"
#include "Vbin2gray___024root.h"

VL_ATTR_COLD void Vbin2gray___024root___eval_static__TOP(Vbin2gray___024root* vlSelf);

VL_ATTR_COLD void Vbin2gray___024root___eval_static(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___eval_static\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vbin2gray___024root___eval_static__TOP(vlSelf);
}

VL_ATTR_COLD void Vbin2gray___024root___eval_static__TOP(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___eval_static__TOP\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.bin2gray_tb__DOT__clk = 0U;
}

VL_ATTR_COLD void Vbin2gray___024root___eval_final(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___eval_final\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vbin2gray___024root___dump_triggers__stl(Vbin2gray___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vbin2gray___024root___eval_phase__stl(Vbin2gray___024root* vlSelf);

VL_ATTR_COLD void Vbin2gray___024root___eval_settle(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___eval_settle\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    IData/*31:0*/ __VstlIterCount;
    CData/*0:0*/ __VstlContinue;
    // Body
    __VstlIterCount = 0U;
    vlSelfRef.__VstlFirstIteration = 1U;
    __VstlContinue = 1U;
    while (__VstlContinue) {
        if (VL_UNLIKELY((0x64U < __VstlIterCount))) {
#ifdef VL_DEBUG
            Vbin2gray___024root___dump_triggers__stl(vlSelf);
#endif
            VL_FATAL_MT("bin2gray_tb.sv", 2, "", "Settle region did not converge.");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
        __VstlContinue = 0U;
        if (Vbin2gray___024root___eval_phase__stl(vlSelf)) {
            __VstlContinue = 1U;
        }
        vlSelfRef.__VstlFirstIteration = 0U;
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vbin2gray___024root___dump_triggers__stl(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___dump_triggers__stl\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VstlTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VstlTriggered.word(0U))) {
        VL_DBG_MSGF("         'stl' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
    if ((2ULL & vlSelfRef.__VstlTriggered.word(0U))) {
        VL_DBG_MSGF("         'stl' region trigger index 1 is active: @([hybrid] bin2gray_tb.b_data_out)\n");
    }
}
#endif  // VL_DEBUG

void Vbin2gray___024root___act_comb__TOP__0(Vbin2gray___024root* vlSelf);
void Vbin2gray___024root___act_comb__TOP__1(Vbin2gray___024root* vlSelf);

VL_ATTR_COLD void Vbin2gray___024root___eval_stl(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___eval_stl\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VstlTriggered.word(0U))) {
        Vbin2gray___024root___act_comb__TOP__0(vlSelf);
    }
    if ((3ULL & vlSelfRef.__VstlTriggered.word(0U))) {
        Vbin2gray___024root___act_comb__TOP__1(vlSelf);
    }
}

VL_ATTR_COLD void Vbin2gray___024root___eval_triggers__stl(Vbin2gray___024root* vlSelf);

VL_ATTR_COLD bool Vbin2gray___024root___eval_phase__stl(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___eval_phase__stl\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VstlExecute;
    // Body
    Vbin2gray___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = vlSelfRef.__VstlTriggered.any();
    if (__VstlExecute) {
        Vbin2gray___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vbin2gray___024root___dump_triggers__act(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___dump_triggers__act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VactTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 0 is active: @([hybrid] bin2gray_tb.b_data_out)\n");
    }
    if ((2ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 1 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
    if ((4ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 2 is active: @(negedge bin2gray_tb.clk)\n");
    }
    if ((8ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 3 is active: @(posedge bin2gray_tb.clk)\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void Vbin2gray___024root___dump_triggers__nba(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___dump_triggers__nba\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VnbaTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 0 is active: @([hybrid] bin2gray_tb.b_data_out)\n");
    }
    if ((2ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 1 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
    if ((4ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 2 is active: @(negedge bin2gray_tb.clk)\n");
    }
    if ((8ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 3 is active: @(posedge bin2gray_tb.clk)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vbin2gray___024root___ctor_var_reset(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___ctor_var_reset\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelf->bin2gray_tb__DOT__b_data_in = VL_RAND_RESET_I(8);
    vlSelf->bin2gray_tb__DOT__g_data_in = VL_RAND_RESET_I(8);
    vlSelf->bin2gray_tb__DOT__b_data_out = VL_RAND_RESET_I(8);
    vlSelf->bin2gray_tb__DOT__clk = VL_RAND_RESET_I(1);
    vlSelf->bin2gray_tb__DOT__unnamedblk1__DOT__test_idx = VL_RAND_RESET_I(32);
    vlSelf->__VdlyVal__bin2gray_tb__DOT__clk__v0 = VL_RAND_RESET_I(1);
    vlSelf->__VdlySet__bin2gray_tb__DOT__clk__v0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__bin2gray_tb__DOT__b_data_out__0 = VL_RAND_RESET_I(8);
    vlSelf->__VstlDidInit = 0;
    vlSelf->__Vtrigprevexpr___TOP__bin2gray_tb__DOT__b_data_out__1 = VL_RAND_RESET_I(8);
    vlSelf->__Vtrigprevexpr___TOP__bin2gray_tb__DOT__clk__0 = VL_RAND_RESET_I(1);
    vlSelf->__VactDidInit = 0;
}
