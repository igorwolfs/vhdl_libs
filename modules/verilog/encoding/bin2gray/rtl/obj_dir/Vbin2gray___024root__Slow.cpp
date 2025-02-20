// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vbin2gray.h for the primary calling header

#include "Vbin2gray__pch.h"
#include "Vbin2gray__Syms.h"
#include "Vbin2gray___024root.h"

// Parameter definitions for Vbin2gray___024root
constexpr VlUnpacked<CData/*7:0*/, 16> Vbin2gray___024root::bin2gray_tb__DOT__TESTS_IN;


void Vbin2gray___024root___ctor_var_reset(Vbin2gray___024root* vlSelf);

Vbin2gray___024root::Vbin2gray___024root(Vbin2gray__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , __VdlySched{*symsp->_vm_contextp__}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vbin2gray___024root___ctor_var_reset(this);
}

void Vbin2gray___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vbin2gray___024root::~Vbin2gray___024root() {
}
