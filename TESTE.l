%option noyywrap nodefault yylineno case-insensitive

%{

 struct symbol{
 	char *name;
 	struct ref *reflist;
 };

 struct ref{
 	struct ref *next;
 	char *filename;
 	int flags;
 	int lineno;
 };

 #define NHASH 9997

 struct symbol symtab[NHASH];
 struct symbol *lookup(char*);
 void addref(int, char *, char*,int);

 char *curfilename; /*nome do arquivo corrente*/
 char *palavra1;
 char *palavra2;
 char *palavra3;


%}

NUM [0-9] 
LETRAS [a-zA-Z]
SIMB [\-\_]
TUM thumb\/
MIDDLE2 \/tweet\_video\_{TUM}
LINK https\:\/\/pbs\.twimg\.com

IG_1 https\:\/\/instagram\.
IG_PADRAO (({LETRAS}|{NUM}|{SIMB}?)*\.)*
IG_PADRAO2 net\/
IG_PADRAONUM ({LETRAS}|{NUM}|\.|{SIMB}?)*\/
IG_PADRAONUM2 ({NUM}*\_)*
IG_EXT \_n\.mp4


%%


{LINK}{MIDDLE2}({LETRAS}|{NUM}|{SIMB}?)*\.   {addref(yylineno,curfilename,yytext,0);
											  
											  printf("Link extraído: %s \n",yytext); 															  palavra1= yytext;
											  palavra2 = strrchr(palavra1,'/');
											  if((palavra1==NULL)||(palavra2 == NULL)||(palavra2<palavra1))
													return 0;
												memmove(palavra1+33,palavra2, strlen(palavra2)+1);
												palavra3 = strcat(palavra1,"mp4");
												printf("Link final: %s\n\n",palavra3);

												FILE *p = fopen("list.txt","w");
												fprintf(p,palavra3);
												fclose(p);

												system("wget -i list.txt");
												
												}



{IG_1}.*{IG_EXT} {addref(yylineno,curfilename,yytext,0);
						printf("Link extraído: %s \n",yytext);
						FILE *p = fopen("list.txt","w");
						fprintf(p,yytext);
						fclose(p);
						system("wget -i list.txt");
						}

.|\n 		


%%

/*funcoes em C*/

static unsigned symhash(char *sym){
	unsigned int hash =0;
	unsigned c;

	while(c = *sym++){
		hash = hash*9^c;
	}

return hash;
}

struct symbol *lookup(char *sym){
	struct symbol *sp = &symtab[symhash(sym)%NHASH];
	int scount = NHASH;

	while(--scount>= 0){
		if(sp->name && !strcasecmp(sp->name,sym))
			return sp;

			if(!sp->name){ 
				sp->name = strdup(sym); //nova entrada
				sp->reflist = 0;
				//printf("entra aqui??");
				return sp;
			}

			if(++sp >= symtab+NHASH){
				sp = symtab; //tenta a prox entrada
			}
	}

	fputs("overflow na tab simbolos \n",stderr);
	abort();
}

void addref(int lineno, char *filename, char *word, int flags){

	struct ref *r;
	struct symbol *sp = lookup(word);

	if(sp->reflist && sp->reflist->lineno == lineno && sp->reflist->filename == filename)
		return;

	r = malloc(sizeof(struct ref));

	if(!r){
		fputs("sem espaço \n",stderr);
		abort();
	}

	r->next = sp->reflist;
	r->filename = filename;
	r->flags = flags;
	sp->reflist = r;

}

static int symcompare(const void *xa, const void *xb){

	const struct symbol *a = xa;
	const struct symbol *b = xb;

	if(!a->name){
		if(!b->name)
			return 0;
	return 1;
	}

	if(!b->name)
		return -1;


	return strcmp(a->name, b->name);

}

void printrefs(){ /* ordenação da tabela*/

	struct symbol *sp, *sp_aux;

	qsort(symtab, NHASH, sizeof(struct symbol), symcompare);

	for(sp == symtab; sp->name && sp<symtab+NHASH; sp++){
		char *prevfn = NULL; //ultimo arquivo impresso
	

	struct ref *rp = sp->reflist;
	struct ref *rpp = 0;
	struct ref *rpn;

	do{
		rpn = rp->next;
		rp->next = rpp;
		rpp = rp;
		rp = rpn;
	}while(rp);


	printf("%10s", sp->name);

	for(rp = rpp; rp; rp = rp->next){
		
		if(rp->filename == prevfn){

			printf("%d", rp->lineno);
		}else{
			printf(" %s:%d", rp->filename, rp->lineno);
			prevfn = rp->filename;
		}
	}

	printf("\n");
	}
}

int main(argc,argv) int argc; char **argv;
{
	int i;

	if(argc <2){
		curfilename = "(stdin)";
		yylineno = 1;
		yylex();
	}else{
		for(i = 1; i < argc; i++){
			FILE *f = fopen(argv[i],"r");

			if(!f){
				perror(argv[i]);
				return(1);
			}

			curfilename = argv[i];

			yyrestart(f);
			yylineno = 1;
			yylex();
			fclose(f);
		}

		
	printrefs();
	}
return 0;
}
