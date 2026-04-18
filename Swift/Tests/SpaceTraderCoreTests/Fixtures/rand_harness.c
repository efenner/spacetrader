/*
 * Golden-vector harness for Space Trader's custom LCG.
 *
 * Compiled standalone with gcc; no Palm SDK required. Uses <stdint.h> to
 * fix UInt16/UInt32 sizes explicitly, matching the semantics that Src/Math.c
 * would see on any compiler where UInt16 is 16-bit unsigned.
 *
 * Build:   gcc -std=c99 -O0 -o rand_harness rand_harness.c
 * Run:     ./rand_harness > rand_seed_default.txt
 *
 * The Swift RNGTests load rand_seed_default.txt and assert bit-for-bit
 * equality with the implementation in SpaceTraderCore/Systems/RNG.swift.
 */
#include <stdio.h>
#include <stdint.h>

typedef uint16_t UInt16;
typedef uint32_t UInt32;

#define MAX_WORD   65535
#define DEFSEEDX   521288629
#define DEFSEEDY   362436069

static UInt16 SeedX = DEFSEEDX;
static UInt16 SeedY = DEFSEEDY;

/* Faithful copy of Rand() from Src/Math.c:90-99. */
static UInt16 Rand(void)
{
    static UInt16 a = 18000;
    static UInt16 b = 30903;

    SeedX = a * (SeedX & MAX_WORD) + (SeedX >> 16);
    SeedY = b * (SeedY & MAX_WORD) + (SeedY >> 16);

    return ((SeedX << 16) + (SeedY & MAX_WORD));
}

/* Faithful copy of RandSeed() from Src/Math.c:101-112. */
static void RandSeed(UInt16 seed1, UInt16 seed2)
{
    SeedX = seed1 ? seed1 : DEFSEEDX;
    SeedY = seed2 ? seed2 : DEFSEEDY;
}

int main(void)
{
    /* Case 1: RandSeed(0,0) default seeds, first 16 outputs. */
    RandSeed(0, 0);
    printf("# Case: default seeds after RandSeed(0,0); first 16 Rand() values\n");
    printf("# seed1=0 seed2=0\n");
    for (int i = 0; i < 16; ++i) {
        printf("%u\n", (unsigned)Rand());
    }

    /* Case 2: RandSeed(1,1), first 16 outputs. */
    RandSeed(1, 1);
    printf("# Case: RandSeed(1,1); first 16 Rand() values\n");
    printf("# seed1=1 seed2=1\n");
    for (int i = 0; i < 16; ++i) {
        printf("%u\n", (unsigned)Rand());
    }

    /* Case 3: RandSeed(12345, 54321), first 16 outputs. */
    RandSeed(12345, 54321);
    printf("# Case: RandSeed(12345,54321); first 16 Rand() values\n");
    printf("# seed1=12345 seed2=54321\n");
    for (int i = 0; i < 16; ++i) {
        printf("%u\n", (unsigned)Rand());
    }

    return 0;
}
