%%%% -*- Mode: Prolog -*-
%%%% Tropeano Pietro 829757
%%%% lmc.pl


%%% lettura file

%% read_all legge tutto il file input con assembly semplificato

read_all(Str, []):-
    at_end_of_stream(Str),
    !.

read_all(Str, [X | Xs]):-
    \+ at_end_of_stream(Str),
    read_line_to_codes(Str, Codes),
    atom_chars(Line, Codes),
    string_lower(Line, X),
    read_all(Str, Xs).


%%% rimozione dei commenti

%% decomment rimuove eventuali commenti da una riga

decomment(Line, NewLine):-
    string_length(Line, Len),
    sub_string(Line, LenBe, 2, LenAf, "//"),
    Len > LenAf,
    !,
    sub_string(Line, 0, LenBe, _, NewLine).

decomment(Line, Line).


%% decomment_all rimuove eventuali commenti da ogni riga in una lista
%% di righe

decomment_all([], []):-!.

decomment_all([X | Xs], [Y | Ys]):-
    decomment(X, Y),
    !,
    decomment_all(Xs, Ys).


%%% gestione etichette

%% is_label verifica che la stringa sia papabile come label e che non
%% esista una label con quel nome

is_label(X):-
    instruction(X, _),
    !,
    fail.

is_label(X):-
    label(X, _),
    !,
    fail.

is_label(_):-!.


%% get_label aggiunge la possibile label di una riga alla lista di
%% label restituendo la stringa senza label

get_label(Line, InsNum, NewLine):-
    split_string(Line, " ", " ", [X | _Xs]),
    is_label(X),
    !,
    assert(label(X, InsNum)),
    string_length(X, LenX),
    sub_string(Line, LenX, _, 0, NewLine).

get_label(Line, _, Line).


%% get_all_labels ottiene tutte le label da una lista di istruzioni

get_all_labels([], _, []):-!.

get_all_labels([X | Xs], Num, [Y | Ys]):-
    get_label(X, Num, Y),
    !,
    Next is Num + 1,
    get_all_labels(Xs, Next, Ys).


%% replace_label sostituisce eventuali label con il valore a loro
%% associato

replace_label(Line, _NewLine):-
    split_string(Line, " ", " ", [Ins, X]),
    label(X, _Num),
    compare(=, "dat", Ins),
    !,
    fail.

replace_label(Line, NewLine):-
    split_string(Line, " ", " ", [Ins, X | _Xs]),
    label(X, Num),
    !,
    string_concat(Ins, " ", ToConcat),
    string_concat(ToConcat, Num, NewLine).

replace_label(Line, Line):-
    split_string(Line, " ", " ", [_Ins, X | _Xs]),
    number_string(_A, X),
    !.

replace_label(Line, Line):-
    split_string(Line, " ", " ", [_X | Xs]),
    length(Xs, 0),
    !.



%% replace_all_labels sostituisce tutte le label di una lista di
%% istruzioni

replace_all_labels([], []):-!.

replace_all_labels([X | Xs], [Y | Ys]):-
    replace_label(X, Y),
    !,
    replace_all_labels(Xs, Ys).


%%% riformattazzione del testo e della lista

%% remove_voids rimuove tutte le righe vuote in una lista di
%% istruzioni. questo predicato si occpupa anche della presenza di
%% spazi eccessivi rimuovendoli.

%% caso in cui ho anche un'etichetta

remove_voids([X | Xs], [NoSpaces | Ys]):-
    split_string(X, " ", " ", [Eti, Ins, Num | _Zs]),
    !,
    string_concat(Eti, " ", ToConcat0),
    string_concat(ToConcat0, Ins, ToConcat1),
    string_concat(ToConcat1, " ", ToConcat2),
    string_concat(ToConcat2, Num, NoSpaces),
    remove_voids(Xs, Ys).

%% caso in cui ho una istruzione seguita da un indirizzo

remove_voids([X | Xs], [NoSpaces | Ys]):-
    split_string(X, " ", " ", [Ins, Num | _Zs]),
    !,
    string_concat(Ins, " ", ToConcat),
    string_concat(ToConcat, Num, NoSpaces),
    remove_voids(Xs, Ys).

%% caso in cui ho una istruzione singola

remove_voids([X | Xs], [Ins | Ys]):-
    split_string(X, " ", " ", [Ins | _Zs]),
    string_length(Ins, Len),
    Len > 0,
    !,
    remove_voids(Xs, Ys).

remove_voids([_ | Xs], Ys):-
    remove_voids(Xs, Ys).

remove_voids([], []).


%%% segue la lista di istruzioni con codice annesso

instruction("add", 1):-!.

instruction("sub", 2):-!.

instruction("sta", 3):-!.

instruction("lda", 5):-!.

instruction("bra", 6):-!.

instruction("brz", 7):-!.

instruction("brp", 8):-!.

instruction("inp", 901):-!.

instruction("out", 902):-!.

instruction("hlt", 0):-!.

instruction("dat", "dat"):-!.


%%% gestione conversione codice assembler -> codice macchina

%% decode si occupa di tradurre una istruzione con il corrispondente
%% codice

decode(Ins, Ins):-
    integer(Ins),
    !.

decode(Line, NewLine):-
    split_string(Line, " ", " ", [Ins, X | _Xs]),
    atom_number(X, NumberX),
    NumberX > 10,
    instruction(Ins, Num),
    !,
    string_concat(Num, X, ToCast),
    number_codes(NewLine, ToCast).

decode(Line, NewLine):-
    split_string(Line, " ", " ", [Ins, X | _Xs]),
    atom_number(X, NumberX),
    NumberX < 10,
    instruction(Ins, Num),
    !,
    string_concat(Num, "0", Partial),
    string_concat(Partial, X, ToCast),
    number_codes(NewLine, ToCast).

decode(Line, NewLine):-
    split_string(Line, " ", " ", [Ins | _Xs]),
    !,
    instruction(Ins, NewLine).

decode(Line, Line).


%% decode_all sostituisce tutte le istruzioni con il codice
%% corrispondente

decode_all([], []):-!.

decode_all([X | Xs], [Y | Ys]):-
    decode(X, Y),
    !,
    decode_all(Xs, Ys).


%% read_dat sostituisce eventuali dat con il valore a loro
%% associato

read_dat(Line, NumX):-
    split_string(Line, " ", " ", [Ins, X | _Xs]),
    compare(=, Ins, "dat"),
    number_codes(NumX, X),
    !.

read_dat(Line, 0):-
    split_string(Line, " ", " ", [Ins | _Xs]),
    compare(=, Ins, "dat"),
    !.

read_dat(Line, Line).


%% read_dats sostituisce tutte le dat di una lista

read_dats([], []):-!.

read_dats([X | Xs], [Y | Ys]):-
    read_dat(X, Y),
    !,
    read_dats(Xs, Ys).


%%% gestione numero istruzioni e creazione memoria

%% add_zeros aggiunge HowMany zeri ad una lista

add_zeros(HowMany, [0 | L]) :-
    HowMany > 0,
    !,
    Decreased is HowMany - 1,
    add_zeros(Decreased, L).

add_zeros(HowMany, []):-
    HowMany = 0.


%% expand verifica che vi siano 100 istruzioni, altrimenti ne aggiunge
%% alcune a 0 fino ad arrivare ad averne 100. se ve ne sono di piu
%% fallisce.

expand(List, NewList):-
    length(List, LenList),
    LenList < 100,
    !,
    HowMany is 100 - LenList,
    add_zeros(HowMany, ToAdd),
    append(List, ToAdd, NewList).

expand(List, List):-
    length(List, LenList),
    LenList = 100.


%% check_list verifica che gli elementi della lista siano conformi alle
%% specifiche (valori compresi tra 0 e 999 estremi inclusi)

check_list([X | Xs]):-
    X > -1,
    X < 1000,
    !,
    check_list(Xs).

check_list([]):-!.


%%% creazione memoria e acquisizione coda di input

%% lmc_load legge un file in input e restituisce in output la memoria
%% (dove istruzioni e memoria non sono differenziate)

lmc_load(Filename, Mem):-
    retractall(label(_, _)),
    open(Filename, read, Str),
    read_all(Str, Readed),
    close(Str),
    decomment_all(Readed, Decommented),
    remove_voids(Decommented, WithNoVoids),
    get_all_labels(WithNoVoids, 0, WithNoLabels),
    replace_all_labels(WithNoLabels, Replaced),
    read_dats(Replaced, WithNoDat),
    decode_all(WithNoDat, Decoded),
    expand(Decoded, Mem),
    check_list(Mem).


%% lmc_run legge un file e dato un input verifica che l'output fornito
%% sia corretto secondo le specifiche del progetto

lmc_run(Filename, In, Out):-
    check_list(In),
    lmc_load(Filename, Mem),
    execution_loop(state(0, 0, Mem, In, [], 0), Out).


%%% gestione degli stati

%% one_instruction dato uno stato produce lo stato successivo

one_instruction(State, NewState):-
    !,
    functor(State, state, 6),
    arg(2, State, Pc),
    arg(3, State, Mem),
    nth0(Pc, Mem, E, _R),
    exec_inst(E, State, NewState).


%% execution_loop esegue la one instruction fino a raggiugere un
%% halted state

execution_loop(State, Out):-
    functor(State, halted_state, 6),
    !,
    arg(5, State, Out).

% caso in cui si provi a leggerre un input ma non vi sono input
% nella coda

execution_loop(State, _Out):-
    functor(State, i_am_a_failure, 1),
    !,
    fail.

execution_loop(State, Out):-
    one_instruction(State, Newstate),
    !,
    execution_loop(Newstate, Out).

execution_loop(state(_, _, _, _, Out, _), Out).


%%% esecuzione istruzioni (aggiornamento stati)

%% add consente di gestire la somma in modulo 1000 (ovvero con valori
%% compresi tra 0 e 999)

add(Val, Acc, Out, F):-
    N is Val + Acc,
    N < 1000,
    N > -1,
    Out is N,
    F is 0,
    !.

add(Val, Acc, Out, F):-
    N is Val + Acc,
    N > 999,
    Out is mod(N, 1000),
    F is 1,
    !.

add(Val, Acc, Out, F):-
    N is Val + Acc,
    N < 0,
    Out is mod(N, 1000),
    F is 1,
    !.


%% exec_inst esegue l'istruzione rappresentata dal codice E,
%% restituendo in output il nuovo stato

% add

exec_inst(E, state(Acc, Pc, M, In, O, _D), state(A, P, M, In, O, F)):-
    E < 200,
    E > 99,
    !,
    X is E - 100,
    nth0(X, M, Val, _R),
    add(Val, Acc, A, F),
    P is Pc + 1.

% sub

exec_inst(E, state(Acc, Pc, M, In, O, _D), state(A, P, M, In, O, F)):-
    E < 300,
    E > 199,
    !,
    X is E - 200,
    nth0(X, M, Val, _R),
    add(-Val, Acc, A, F),
    P is Pc + 1.

% store

exec_inst(E, state(A, Pc, Mem, I, O, F), state(A, P, Nmem, I, O, F)):-
    E < 400,
    E > 299,
    !,
    X is E - 300,
    nth0(X, Mem, _Val, R),
    nth0(X, Nmem, A, R),
    P is Pc + 1.

% load

exec_inst(E, state(_Ac, Pc, M, I, O, F), state(A, P, M, I, O, F)):-
    E < 600,
    E > 499,
    !,
    X is E - 500,
    nth0(X, M, A, _R),
    P is Pc + 1.

% branch

exec_inst(E, state(A, _Pc, M, I, O, F), state(A, X, M, I, O, F)):-
    E < 700,
    E > 599,
    !,
    X is E - 600.

% branch if zero

exec_inst(E, state(0, _Pc, M, I, O, 0), state(0, X, M, I, O, 0)):-
    E < 800,
    E > 699,
    !,
    X is E - 700.

% branch if zero

exec_inst(E, state(A, Pc, M, I, O, F), state(A, X, M, I, O, F)):-
    E < 800,
    E > 699,
    !,
    X is Pc + 1.

% branch if positive

exec_inst(E, state(A, _Pc, M, I, O, F), state(A, X, M, I, O, F)):-
    E < 900,
    E > 799,
    F = 0,
    !,
    X is E - 800.

% branch if positive

exec_inst(E, state(A, Pc, M, I, O, F), state(A, X, M, I, O, F)):-
    E < 900,
    E > 799,
    !,
    X is Pc + 1.

% input

exec_inst(E, state(_A, _Pc, _M, X, _O, _F), i_am_a_failure("ops")):-
    E = 901,
    length(X, Y),
    Y < 1,
    !.

exec_inst(E, state(_A, Pc, M, [X | Xs], O, F), state(X, P, M, Xs, O, F)):-
    E = 901,
    !,
    length([X | Xs], Y),
    Y > 0,
    P is Pc + 1.

% output

exec_inst(E, state(A, Pc, M, In, Out, F), state(A, P, M, In, Nout, F)):-
    E = 902,
    !,
    append(Out, [A], Nout),
    P is Pc + 1.

% halt

exec_inst(E, state(A, Pc, M, I, O, F), halted_state(A, Pc, M, I, O, F)):-
    E < 100,
    E > -1,
    !.


%%%% end of file -- lmc.pl





















