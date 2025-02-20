// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vbin2gray.h for the primary calling header

#include "Vbin2gray__pch.h"
#include "Vbin2gray__Syms.h"
#include "Vbin2gray___024root.h"

VL_INLINE_OPT VlCoroutine Vbin2gray___024root___eval_initial__TOP__Vtiming__0(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___eval_initial__TOP__Vtiming__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSymsp->_vm_contextp__->dumpfile(std::string{"vars.vcd"});
    co_await vlSelfRef.__VtrigSched_h26928890__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         33);
    vlSelfRef.bin2gray_tb__DOT__b_data_in = 0x10U;
    co_await vlSelfRef.__VtrigSched_h26928921__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         38);
    if ((0x10U == (IData)(vlSelfRef.bin2gray_tb__DOT__b_data_out))) {
        VL_WRITEF_NX("Test           0 success!\n",0);
    } else {
        VL_WRITEF_NX("Test           0 FAIL\n",0);
    }
    vlSelfRef.bin2gray_tb__DOT__unnamedblk1__DOT__test_idx = 1U;
    co_await vlSelfRef.__VtrigSched_h26928890__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         33);
    vlSelfRef.bin2gray_tb__DOT__b_data_in = 1U;
    co_await vlSelfRef.__VtrigSched_h26928921__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         38);
    if ((1U == (IData)(vlSelfRef.bin2gray_tb__DOT__b_data_out))) {
        VL_WRITEF_NX("Test           1 success!\n",0);
    } else {
        VL_WRITEF_NX("Test           1 FAIL\n",0);
    }
    vlSelfRef.bin2gray_tb__DOT__unnamedblk1__DOT__test_idx = 2U;
    co_await vlSelfRef.__VtrigSched_h26928890__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         33);
    vlSelfRef.bin2gray_tb__DOT__b_data_in = 0x91U;
    co_await vlSelfRef.__VtrigSched_h26928921__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         38);
    if ((0x91U == (IData)(vlSelfRef.bin2gray_tb__DOT__b_data_out))) {
        VL_WRITEF_NX("Test           2 success!\n",0);
    } else {
        VL_WRITEF_NX("Test           2 FAIL\n",0);
    }
    vlSelfRef.bin2gray_tb__DOT__unnamedblk1__DOT__test_idx = 3U;
    co_await vlSelfRef.__VtrigSched_h26928890__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         33);
    vlSelfRef.bin2gray_tb__DOT__b_data_in = 0xabU;
    co_await vlSelfRef.__VtrigSched_h26928921__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         38);
    if ((0xabU == (IData)(vlSelfRef.bin2gray_tb__DOT__b_data_out))) {
        VL_WRITEF_NX("Test           3 success!\n",0);
    } else {
        VL_WRITEF_NX("Test           3 FAIL\n",0);
    }
    vlSelfRef.bin2gray_tb__DOT__unnamedblk1__DOT__test_idx = 4U;
    co_await vlSelfRef.__VtrigSched_h26928890__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         33);
    vlSelfRef.bin2gray_tb__DOT__b_data_in = 0xbaU;
    co_await vlSelfRef.__VtrigSched_h26928921__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         38);
    if ((0xbaU == (IData)(vlSelfRef.bin2gray_tb__DOT__b_data_out))) {
        VL_WRITEF_NX("Test           4 success!\n",0);
    } else {
        VL_WRITEF_NX("Test           4 FAIL\n",0);
    }
    vlSelfRef.bin2gray_tb__DOT__unnamedblk1__DOT__test_idx = 5U;
    co_await vlSelfRef.__VtrigSched_h26928890__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         33);
    vlSelfRef.bin2gray_tb__DOT__b_data_in = 0xafU;
    co_await vlSelfRef.__VtrigSched_h26928921__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         38);
    if ((0xafU == (IData)(vlSelfRef.bin2gray_tb__DOT__b_data_out))) {
        VL_WRITEF_NX("Test           5 success!\n",0);
    } else {
        VL_WRITEF_NX("Test           5 FAIL\n",0);
    }
    vlSelfRef.bin2gray_tb__DOT__unnamedblk1__DOT__test_idx = 6U;
    co_await vlSelfRef.__VtrigSched_h26928890__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         33);
    vlSelfRef.bin2gray_tb__DOT__b_data_in = 0xfaU;
    co_await vlSelfRef.__VtrigSched_h26928921__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         38);
    if ((0xfaU == (IData)(vlSelfRef.bin2gray_tb__DOT__b_data_out))) {
        VL_WRITEF_NX("Test           6 success!\n",0);
    } else {
        VL_WRITEF_NX("Test           6 FAIL\n",0);
    }
    vlSelfRef.bin2gray_tb__DOT__unnamedblk1__DOT__test_idx = 7U;
    co_await vlSelfRef.__VtrigSched_h26928890__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         33);
    vlSelfRef.bin2gray_tb__DOT__b_data_in = 0x22U;
    co_await vlSelfRef.__VtrigSched_h26928921__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         38);
    if ((0x22U == (IData)(vlSelfRef.bin2gray_tb__DOT__b_data_out))) {
        VL_WRITEF_NX("Test           7 success!\n",0);
    } else {
        VL_WRITEF_NX("Test           7 FAIL\n",0);
    }
    vlSelfRef.bin2gray_tb__DOT__unnamedblk1__DOT__test_idx = 8U;
    co_await vlSelfRef.__VtrigSched_h26928890__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         33);
    vlSelfRef.bin2gray_tb__DOT__b_data_in = 0x11U;
    co_await vlSelfRef.__VtrigSched_h26928921__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         38);
    if ((0x11U == (IData)(vlSelfRef.bin2gray_tb__DOT__b_data_out))) {
        VL_WRITEF_NX("Test           8 success!\n",0);
    } else {
        VL_WRITEF_NX("Test           8 FAIL\n",0);
    }
    vlSelfRef.bin2gray_tb__DOT__unnamedblk1__DOT__test_idx = 9U;
    co_await vlSelfRef.__VtrigSched_h26928890__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         33);
    vlSelfRef.bin2gray_tb__DOT__b_data_in = 0x99U;
    co_await vlSelfRef.__VtrigSched_h26928921__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         38);
    if ((0x99U == (IData)(vlSelfRef.bin2gray_tb__DOT__b_data_out))) {
        VL_WRITEF_NX("Test           9 success!\n",0);
    } else {
        VL_WRITEF_NX("Test           9 FAIL\n",0);
    }
    vlSelfRef.bin2gray_tb__DOT__unnamedblk1__DOT__test_idx = 0xaU;
    co_await vlSelfRef.__VtrigSched_h26928890__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         33);
    vlSelfRef.bin2gray_tb__DOT__b_data_in = 0x11U;
    co_await vlSelfRef.__VtrigSched_h26928921__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         38);
    if ((0x11U == (IData)(vlSelfRef.bin2gray_tb__DOT__b_data_out))) {
        VL_WRITEF_NX("Test          10 success!\n",0);
    } else {
        VL_WRITEF_NX("Test          10 FAIL\n",0);
    }
    vlSelfRef.bin2gray_tb__DOT__unnamedblk1__DOT__test_idx = 0xbU;
    co_await vlSelfRef.__VtrigSched_h26928890__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         33);
    vlSelfRef.bin2gray_tb__DOT__b_data_in = 0U;
    co_await vlSelfRef.__VtrigSched_h26928921__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         38);
    if ((0U == (IData)(vlSelfRef.bin2gray_tb__DOT__b_data_out))) {
        VL_WRITEF_NX("Test          11 success!\n",0);
    } else {
        VL_WRITEF_NX("Test          11 FAIL\n",0);
    }
    vlSelfRef.bin2gray_tb__DOT__unnamedblk1__DOT__test_idx = 0xcU;
    co_await vlSelfRef.__VtrigSched_h26928890__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         33);
    vlSelfRef.bin2gray_tb__DOT__b_data_in = 0x13U;
    co_await vlSelfRef.__VtrigSched_h26928921__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         38);
    if ((0x13U == (IData)(vlSelfRef.bin2gray_tb__DOT__b_data_out))) {
        VL_WRITEF_NX("Test          12 success!\n",0);
    } else {
        VL_WRITEF_NX("Test          12 FAIL\n",0);
    }
    vlSelfRef.bin2gray_tb__DOT__unnamedblk1__DOT__test_idx = 0xdU;
    co_await vlSelfRef.__VtrigSched_h26928890__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         33);
    vlSelfRef.bin2gray_tb__DOT__b_data_in = 0xffU;
    co_await vlSelfRef.__VtrigSched_h26928921__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         38);
    if ((0xffU == (IData)(vlSelfRef.bin2gray_tb__DOT__b_data_out))) {
        VL_WRITEF_NX("Test          13 success!\n",0);
    } else {
        VL_WRITEF_NX("Test          13 FAIL\n",0);
    }
    vlSelfRef.bin2gray_tb__DOT__unnamedblk1__DOT__test_idx = 0xeU;
    co_await vlSelfRef.__VtrigSched_h26928890__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         33);
    vlSelfRef.bin2gray_tb__DOT__b_data_in = 0x25U;
    co_await vlSelfRef.__VtrigSched_h26928921__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         38);
    if ((0x25U == (IData)(vlSelfRef.bin2gray_tb__DOT__b_data_out))) {
        VL_WRITEF_NX("Test          14 success!\n",0);
    } else {
        VL_WRITEF_NX("Test          14 FAIL\n",0);
    }
    vlSelfRef.bin2gray_tb__DOT__unnamedblk1__DOT__test_idx = 0xfU;
    co_await vlSelfRef.__VtrigSched_h26928890__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         33);
    vlSelfRef.bin2gray_tb__DOT__b_data_in = 0x23U;
    co_await vlSelfRef.__VtrigSched_h26928921__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge bin2gray_tb.clk)", 
                                                         "bin2gray_tb.sv", 
                                                         38);
    if ((0x23U == (IData)(vlSelfRef.bin2gray_tb__DOT__b_data_out))) {
        VL_WRITEF_NX("Test          15 success!\n",0);
    } else {
        VL_WRITEF_NX("Test          15 FAIL\n",0);
    }
    vlSelfRef.bin2gray_tb__DOT__unnamedblk1__DOT__test_idx = 0x10U;
    vlSymsp->_vm_contextp__->dumpfile(std::string{"vars.vcd"});
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vbin2gray___024root___dump_triggers__act(Vbin2gray___024root* vlSelf);
#endif  // VL_DEBUG

void Vbin2gray___024root___eval_triggers__act(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___eval_triggers__act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VactTriggered.set(0U, ((IData)(vlSelfRef.bin2gray_tb__DOT__b_data_out) 
                                       != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__bin2gray_tb__DOT__b_data_out__1)));
    vlSelfRef.__VactTriggered.set(1U, vlSelfRef.__VdlySched.awaitingCurrentTime());
    vlSelfRef.__VactTriggered.set(2U, ((~ (IData)(vlSelfRef.bin2gray_tb__DOT__clk)) 
                                       & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__bin2gray_tb__DOT__clk__0)));
    vlSelfRef.__VactTriggered.set(3U, ((IData)(vlSelfRef.bin2gray_tb__DOT__clk) 
                                       & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__bin2gray_tb__DOT__clk__0))));
    vlSelfRef.__Vtrigprevexpr___TOP__bin2gray_tb__DOT__b_data_out__1 
        = vlSelfRef.bin2gray_tb__DOT__b_data_out;
    vlSelfRef.__Vtrigprevexpr___TOP__bin2gray_tb__DOT__clk__0 
        = vlSelfRef.bin2gray_tb__DOT__clk;
    if (VL_UNLIKELY((1U & (~ (IData)(vlSelfRef.__VactDidInit))))) {
        vlSelfRef.__VactDidInit = 1U;
        vlSelfRef.__VactTriggered.set(0U, 1U);
    }
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vbin2gray___024root___dump_triggers__act(vlSelf);
    }
#endif
}
