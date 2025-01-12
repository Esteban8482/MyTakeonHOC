#include <math.h>
#include <errno.h>
extern int errno;
double errcheck();

double Log(x)
    double x;
{
    return errcheck(log(x), "log");
}
double Log10(x)
    double x;
{
    return errcheck(log10(x), "log10");
}
double Exp(x)
    double x;
{
    return errcheck(exp(x), "exp");
}
double Sqrt(x)
    double x;
{
    return errcheck(sqrt(x), "sqrt");
}
double Pow(x, y)
    double x, y;
{
    return errcheck(pow(x, y), "exponentiation");
}
double integer(x)
    double x;
{
    return (double) (long) x;
}
double errcheck(d, s)
    double d;
    char *s;
{
    if (errno == EDOM) {
        errno = 0;
        execerror(s, "argument out of domain");
    }
    if (errno == ERANGE) {
        errno = 0;
        execerror(s, "result out of range");
    }
    return d;
}