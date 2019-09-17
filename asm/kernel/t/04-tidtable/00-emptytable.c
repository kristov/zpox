#include <z8t.h>
#include <stdio.h>

int main(int argc, char* argv[]) {
    struct z8t_t z8t;
    z8t_init(&z8t, argc, argv);
    z8t_run(&z8t, 0);
    z8t_reg_l_is(&z8t, 0x01, "Register L has correct index");
    z8t_reg_ix_is(&z8t, 0x0115, "Address of entry 1 in IX correct");
    z8t_report(&z8t);
    return 0;
}
