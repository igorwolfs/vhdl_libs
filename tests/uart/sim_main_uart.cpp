#include <verilated.h>
#include "verilated_vcd_c.h"
#include "Vuart_tb.h"

int main(int argc, char **argv)
{
    // Construct context object, design object, and trace object
    VerilatedContext *m_contextp = new VerilatedContext; // Context
    VerilatedVcdC *m_tracep = new VerilatedVcdC;         // Trace
    Vuart_tb *m_duvp = new Vuart_tb;                 // Design
    // Trace configuration
    m_contextp->traceEverOn(true);     // Turn on trace switch in context
    m_duvp->trace(m_tracep, 3);        // Set depth to 3
    m_tracep->open("uart.vcd"); // Open the VCD file to store data
    // Write data to the waveform file
    while (!m_contextp->gotFinish())
    {
        // Refresh circuit state
        m_duvp->eval();
        // Dump data
        m_tracep->dump(m_contextp->time());
        // Increase simulation time
        m_contextp->timeInc(1);
    }
    // Remember to close the trace object to save data in the file
    m_tracep->close();
    // Free memory
    delete m_duvp;
    return 0;
}