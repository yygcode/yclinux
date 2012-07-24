#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

struct slist {
	struct slist *next;
	int data;
};

struct slist* reverse(struct slist *head)
{
	struct slist *next, *p = NULL;

	while (head->next) {
		next = head->next;
		head->next = p;
		p = head;
		head = next;
	}
	head->next = p;

	return head;
}

int main()
{
	int i;
	struct slist head = { .next = NULL, }, *p;

	for (i = 0; i < 10; ++i) {
		p = (struct slist*)malloc(sizeof(*p));
		if (!p) return 1;
		p->data = 9-i;
		p->next = head.next;
		head.next = p;
	}

	p = head.next;
	while (p) {
		printf("%d ", p->data);
		p = p->next;
	}
	printf("\n");

	head.next = reverse(head.next);
	p = head.next;
	while (p) {
		printf("%d ", p->data);
		p = p->next;
	}
	printf("\n");

	return 0;
}
