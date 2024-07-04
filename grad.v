module gradient_descent_timer(
    input clk,            // Clock input (100 MHz onboard clock)
    input rst,            // Reset input
    input start,          // Start computation signal
    output reg [31:0] time_elapsed, // Time elapsed in clock cycles
    output reg [31:0] flops_count,  // Floating Point Operations count
    output reg done       // Computation completion flag
);

    // Constants for fixed-point calculations (6th order precision)
    localparam FIXED_ONE = 32'd1000000; // Fixed-point representation of 1
    localparam LEARNING_RATE = 32'd10;  // Learning rate scaled by FIXED_ONE
    localparam THRESHOLD = 32'd100;     // Threshold for convergence
    localparam MAX_ITER = 1000;         // Maximum iterations

    // Internal variables
    reg [31:0] counter;                 // Iteration counter
    reg [31:0] x;                       // Current value of x
    reg [31:0] flops;                   // FLOPs counter
    wire [31:0] grad;                   // Gradient
    wire [31:0] x_update;               // Updated value of x

    // Computation of gradient: f'(x) = 2*(x - 3*FIXED_ONE)
    assign grad = (x > 3 * FIXED_ONE) ? (x - 3 * FIXED_ONE) << 1 : (3 * FIXED_ONE - x) << 1;

    // Update rule for gradient descent
    assign x_update = x - ((LEARNING_RATE * grad) / FIXED_ONE);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            x <= FIXED_ONE * 5; // Initial guess (5.0)
            flops <= 0;
            done <= 0;
            time_elapsed <= 0;
            flops_count <= 0;
        end else if (start && !done) begin
            if (counter < MAX_ITER) begin
                x <= x_update;
                counter <= counter + 1;
                flops <= flops + 5; // 2 for subtraction, 2 for multiplication, 1 for division
                if (grad < THRESHOLD) begin
                    done <= 1;
                    flops_count <= flops;
                    time_elapsed <= counter; // Time elapsed in terms of clock cycles
                end
            end else begin
                done <= 1;
                flops_count <= flops;
                time_elapsed <= counter; // Time elapsed in terms of clock cycles
            end
        end
    end
endmodule
