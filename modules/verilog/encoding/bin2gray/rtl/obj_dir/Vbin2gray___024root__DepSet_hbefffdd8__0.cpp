// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vbin2gray.h for the primary calling header

#include "Vbin2gray__pch.h"
#include "Vbin2gray___024root.h"

VlCoroutine Vbin2gray___024root___eval_initial__TOP__Vtiming__0(Vbin2gray___024root* vlSelf);
VlCoroutine Vbin2gray___024root___eval_initial__TOP__Vtiming__1(Vbin2gray___024root* vlSelf);

void Vbin2gray___024root___eval_initial(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___eval_initial\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vbin2gray___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    Vbin2gray___024root___eval_initial__TOP__Vtiming__1(vlSelf);
    vlSelfRef.__Vtrigprevexpr___TOP__bin2gray_tb__DOT__b_data_out__0 
        = vlSelfRef.bin2gray_tb__DOT__b_data_out;
    vlSelfRef.__Vtrigprevexpr___TOP__bin2gray_tb__DOT__b_data_out__1 
        = vlSelfRef.bin2gray_tb__DOT__b_data_out;
    vlSelfRef.__Vtrigprevexpr___TOP__bin2gray_tb__DOT__clk__0 
        = vlSelfRef.bin2gray_tb__DOT__clk;
}

VL_INLINE_OPT VlCoroutine Vbin2gray___024root___eval_initial__TOP__Vtiming__1(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___eval_initial__TOP__Vtiming__1\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    while (1U) {
        co_await vlSelfRef.__VdlySched.delay(0x1f4ULL, 
                                             nullptr, 
                                             "bin2gray_tb.sv", 
                                             25);
        vlSelfRef.__VdlyVal__bin2gray_tb__DOT__clk__v0 
            = (1U & (~ (IData)(vlSelfRef.bin2gray_tb__DOT__clk)));
        vlSelfRef.__VdlySet__bin2gray_tb__DOT__clk__v0 = 1U;
    }
}

void Vbin2gray___024root___act_comb__TOP__0(Vbin2gray___024root* vlSelf);
void Vbin2gray___024root___act_comb__TOP__1(Vbin2gray___024root* vlSelf);

void Vbin2gray___024root___eval_act(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___eval_act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((0xcULL & vlSelfRef.__VactTriggered.word(0U))) {
        Vbin2gray___024root___act_comb__TOP__0(vlSelf);
    }
    if ((0xdULL & vlSelfRef.__VactTriggered.word(0U))) {
        Vbin2gray___024root___act_comb__TOP__1(vlSelf);
    }
}

VL_INLINE_OPT void Vbin2gray___024root___act_comb__TOP__0(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___act_comb__TOP__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.bin2gray_tb__DOT__g_data_in = ((0x80U 
                                              & (IData)(vlSelfRef.bin2gray_tb__DOT__b_data_in)) 
                                             | (0x7fU 
                                                & ((IData)(vlSelfRef.bin2gray_tb__DOT__b_data_in) 
                                                   ^ 
                                                   ((IData)(vlSelfRef.bin2gray_tb__DOT__b_data_in) 
                                                    >> 1U))));
}

VL_INLINE_OPT void Vbin2gray___024root___act_comb__TOP__1(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___act_comb__TOP__1\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.bin2gray_tb__DOT__b_data_out = ((0x80U 
                                               & (IData)(vlSelfRef.bin2gray_tb__DOT__g_data_in)) 
                                              | (0x7fU 
                                                 & (((IData)(vlSelfRef.bin2gray_tb__DOT__b_data_out) 
                                                     >> 1U) 
                                                    ^ (IData)(vlSelfRef.bin2gray_tb__DOT__g_data_in))));
}

void Vbin2gray___024root___nba_sequent__TOP__0(Vbin2gray___024root* vlSelf);

void Vbin2gray___024root___eval_nba(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___eval_nba\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((2ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vbin2gray___024root___nba_sequent__TOP__0(vlSelf);
    }
}

VL_INLINE_OPT void Vbin2gray___024root___nba_sequent__TOP__0(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___nba_sequent__TOP__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (vlSelfRef.__VdlySet__bin2gray_tb__DOT__clk__v0) {
        vlSelfRef.__VdlySet__bin2gray_tb__DOT__clk__v0 = 0U;
        vlSelfRef.bin2gray_tb__DOT__clk = vlSelfRef.__VdlyVal__bin2gray_tb__DOT__clk__v0;
    }
}

void Vbin2gray___024root___timing_resume(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___timing_resume\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((4ULL & vlSelfRef.__VactTriggered.word(0U))) {
        vlSelfRef.__VtrigSched_h26928890__0.resume(
                                                   "@(negedge bin2gray_tb.clk)");
    }
    if ((8ULL & vlSelfRef.__VactTriggered.word(0U))) {
        vlSelfRef.__VtrigSched_h26928921__0.resume(
                                                   "@(posedge bin2gray_tb.clk)");
    }
    if ((2ULL & vlSelfRef.__VactTriggered.word(0U))) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vbin2gray___024root___timing_commit(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___timing_commit\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((! (4ULL & vlSelfRef.__VactTriggered.word(0U)))) {
        vlSelfRef.__VtrigSched_h26928890__0.commit(
                                                   "@(negedge bin2gray_tb.clk)");
    }
    if ((! (8ULL & vlSelfRef.__VactTriggered.word(0U)))) {
        vlSelfRef.__VtrigSched_h26928921__0.commit(
                                                   "@(posedge bin2gray_tb.clk)");
    }
}

void Vbin2gray___024root___eval_triggers__act(Vbin2gray___024root* vlSelf);

bool Vbin2gray___024root___eval_phase__act(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___eval_phase__act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    VlTriggerVec<4> __VpreTriggered;
    CData/*0:0*/ __VactExecute;
    // Body
    Vbin2gray___024root___eval_triggers__act(vlSelf);
    Vbin2gray___024root___timing_commit(vlSelf);
    __VactExecute = vlSelfRef.__VactTriggered.any();
    if (__VactExecute) {
        __VpreTriggered.andNot(vlSelfRef.__VactTriggered, vlSelfRef.__VnbaTriggered);
        vlSelfRef.__VnbaTriggered.thisOr(vlSelfRef.__VactTriggered);
        Vbin2gray___024root___timing_resume(vlSelf);
        Vbin2gray___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Vbin2gray___024root___eval_phase__nba(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___eval_phase__nba\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = vlSelfRef.__VnbaTriggered.any();
    if (__VnbaExecute) {
        Vbin2gray___024root___eval_nba(vlSelf);
        vlSelfRef.__VnbaTriggered.clear();
    }
    return (__VnbaExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vbin2gray___024root___dump_triggers__nba(Vbin2gray___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vbin2gray___024root___dump_triggers__act(Vbin2gray___024root* vlSelf);
#endif  // VL_DEBUG

void Vbin2gray___024root___eval(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___eval\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    IData/*31:0*/ __VnbaIterCount;
    CData/*0:0*/ __VnbaContinue;
    // Body
    __VnbaIterCount = 0U;
    __VnbaContinue = 1U;
    while (__VnbaContinue) {
        if (VL_UNLIKELY((0x64U < __VnbaIterCount))) {
#ifdef VL_DEBUG
            Vbin2gray___024root___dump_triggers__nba(vlSelf);
#endif
            VL_FATAL_MT("bin2gray_tb.sv", 2, "", "NBA region did not converge.");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        __VnbaContinue = 0U;
        vlSelfRef.__VactIterCount = 0U;
        vlSelfRef.__VactContinue = 1U;
        while (vlSelfRef.__VactContinue) {
            if (VL_UNLIKELY((0x64U < vlSelfRef.__VactIterCount))) {
#ifdef VL_DEBUG
                Vbin2gray___024root___dump_triggers__act(vlSelf);
#endif
                VL_FATAL_MT("bin2gray_tb.sv", 2, "", "Active region did not converge.");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
            vlSelfRef.__VactContinue = 0U;
            if (Vbin2gray___024root___eval_phase__act(vlSelf)) {
                vlSelfRef.__VactContinue = 1U;
            }
        }
        if (Vbin2gray___024root___eval_phase__nba(vlSelf)) {
            __VnbaContinue = 1U;
        }
    }
}

#ifdef VL_DEBUG
void Vbin2gray___024root___eval_debug_assertions(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___eval_debug_assertions\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
