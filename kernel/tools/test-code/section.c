#include <stdio.h>

typedef int (*initcall_t)(void);

#define __define_initcall(level, fn, id)	\
	static initcall_t __initcall_##fn##id	\
	__attribute__((__section__(".initcall" level ".init"))) = fn


#define early_initcall(fn)		__define_initcall("early",fn,early)

int begin(void) {};
int end(void) {};
early_initcall(begin);

int f(void)
{
	printf("%s %d %s\n", __FILE__, __LINE__, __func__);
}
early_initcall(f);

int g(void)
{
	printf("%s %d %s\n", __FILE__, __LINE__, __func__);
}
early_initcall(g);

int h(void)
{
	printf("%s %d %s\n", __FILE__, __LINE__, __func__);
}
early_initcall(h);

early_initcall(end);

int main()
{
	initcall_t *p;

	for (p = &__initcall_beginearly+1; p < &__initcall_endearly; ++p)
		(*p)();

	return 0;
}
