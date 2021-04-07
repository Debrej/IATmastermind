BEGIN {
	nb_coups = 0;
    nb_tests = 0;
}

{
    nb_coups += $1;
    nb_tests += 1;
}

END {
    printf("%6f\n", nb_coups/nb_tests);
}