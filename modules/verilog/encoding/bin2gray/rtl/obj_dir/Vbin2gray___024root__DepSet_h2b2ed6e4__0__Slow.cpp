// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vbin2gray.h for the primary calling header

#include "Vbin2gray__pch.h"
#include "Vbin2gray__Syms.h"
#include "Vbin2gray___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vbin2gray___024root___dump_triggers__stl(Vbin2gray___024root* vlSelf);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vbin2gray___024root___eval_triggers__stl(Vbin2gray___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vbin2gray__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbin2gray___024root___eval_triggers__stl\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VstlTriggered.set(0U, (IData)(vlSelfRef.__VstlFirstIteration));
    vlSelfRef.__VstlTriggered.set(1U, ((IData)(vlSelfRef.bin2gray_tb__DOT__b_data_out) 
                                       != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__bin2gray_tb__DOT__b_data_out__0)));
    vlSelfRef.__Vtrigprevexpr___TOP__bin2gray_tb__DOT__b_data_out__0 
        = vlSelfRef.bin2gray_tb__DOT__b_data_out;
    if (VL_UNLIKELY((1U & (~ (IData)(vlSelfRef.__VstlDidInit))))) {
        vlSelfRef.__VstlDidInit = 1U;
        vlSelfRef.__VstlTriggered.set(1U, 1U);
    }
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vbin2gray___024root___dump_triggers__stl(vlSelf);
    }
#endif
}
