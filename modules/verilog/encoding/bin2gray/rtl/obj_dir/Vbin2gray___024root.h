// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vbin2gray.h for the primary calling header

#ifndef VERILATED_VBIN2GRAY___024ROOT_H_
#define VERILATED_VBIN2GRAY___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vbin2gray__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vbin2gray___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    CData/*0:0*/ bin2gray_tb__DOT__clk;
    CData/*7:0*/ bin2gray_tb__DOT__b_data_in;
    CData/*7:0*/ bin2gray_tb__DOT__g_data_in;
    CData/*7:0*/ bin2gray_tb__DOT__b_data_out;
    CData/*0:0*/ __VdlyVal__bin2gray_tb__DOT__clk__v0;
    CData/*0:0*/ __VdlySet__bin2gray_tb__DOT__clk__v0;
    CData/*7:0*/ __Vtrigprevexpr___TOP__bin2gray_tb__DOT__b_data_out__0;
    CData/*0:0*/ __VstlDidInit;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*7:0*/ __Vtrigprevexpr___TOP__bin2gray_tb__DOT__b_data_out__1;
    CData/*0:0*/ __Vtrigprevexpr___TOP__bin2gray_tb__DOT__clk__0;
    CData/*0:0*/ __VactDidInit;
    CData/*0:0*/ __VactContinue;
    IData/*31:0*/ bin2gray_tb__DOT__unnamedblk1__DOT__test_idx;
    IData/*31:0*/ __VactIterCount;
    VlDelayScheduler __VdlySched;
    VlTriggerScheduler __VtrigSched_h26928890__0;
    VlTriggerScheduler __VtrigSched_h26928921__0;
    VlTriggerVec<2> __VstlTriggered;
    VlTriggerVec<4> __VactTriggered;
    VlTriggerVec<4> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vbin2gray__Syms* const vlSymsp;

    // PARAMETERS
    static constexpr VlUnpacked<CData/*7:0*/, 16> bin2gray_tb__DOT__TESTS_IN = {{
        0x10U, 0x01U, 0x91U, 0xabU, 0xbaU, 0xafU, 0xfaU, 0x22U,
        0x11U, 0x99U, 0x11U, 0x00U, 0x13U, 0xffU, 0x25U, 0x23U
    }};

    // CONSTRUCTORS
    Vbin2gray___024root(Vbin2gray__Syms* symsp, const char* v__name);
    ~Vbin2gray___024root();
    VL_UNCOPYABLE(Vbin2gray___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
