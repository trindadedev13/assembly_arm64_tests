.section .data
msg:
    .asciz "Hello, World From Arm Asm!\n"

.section .text
.global _start

////// BEGIN PRINT    //////
.global printstr

printstr:
    mov    x4, x0             // x4 = pointer to string
    mov    x2, 0              // x2 = byte counter

count_loop:
    ldrb   w3, [x4, x2]      // load byte at position x4+x2
    cbz    w3, count_done     // if it is zero, it ends
    add    x2, x2, 1          // increment size
    b      count_loop

count_done:
    mov    x1, x0             // x1 = string
    mov    x0, 1              // x0 = stdout (fd 1)
    mov    x8, 64             // syscall: write
    svc    0
    ret

////// END PRINT      //////

////// BEGIN WINDOW   //////

.global    open_window
.extern    XOpenDisplay
.extern    XDefaultScreen
.extern    XRootWindow
.extern    XBlackPixel
.extern    XWhitePixel
.extern    XCreateSimpleWindow
.extern    XMapWindow
.extern    XPending

open_window:
    // XOpenDisplay(NULL)
    mov    x0, #0
    bl     XOpenDisplay
    mov    x19, x0

    // XDefaultScreen(display)
    mov    x0, x19
    bl     XDefaultScreen
    mov    w20, w0

    // XRootWindow(display, screen)
    mov    x0, x19
    mov    w1, w20
    bl     XRootWindow
    mov    x21, x0

    // XBlackPixel(display, screen)
    mov    x0, x19
    mov    w1, w20
    bl     XBlackPixel
    mov    x22, x0

    // XWhitePixel(display, screen)
    mov    x0, x19
    mov    w1, w20
    bl    XWhitePixel
    mov    x23, x0

    // XCreateSimpleWidow(display, root, 10, 10, 400, 300, 1, fg, bg)
    mov    x0, x19            // Display
    mov    x1, x21            // Root
    mov    x2, #10            // X
    mov    x3, #10            // Y
    mov    x4, #400           // width
    mov    x5, #400           // height
    mov    x6, #1             // border_width
    mov    x7, x22            // fg
    mov    x8, x23            // bg

    bl     XCreateSimpleWindow

    mov    x24, x0            // save window in x24

    // XMapWindow(display, window)
    mov    x0, x19
    mov    x1, x24
    bl     XMapWindow

    // XFlush(display)
    mov    x0, x19
    bl     XFlush

loop:
    mov x0, x19
    bl  XPending
    b   loop

    ret

////// END WINDOW     //////


_start:
    // Load pointer to msg
    adrp   x0, msg
    add    x0, x0, :lo12:msg
    bl     printstr

    bl     open_window

    // exit
    mov    x0, 0          // return status = 0
    mov    x8, 93         // syscall exit
    svc    0              // invole syscall