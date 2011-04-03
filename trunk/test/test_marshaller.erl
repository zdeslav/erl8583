%% Author: carl
%% Created: 02 Apr 2011
%% Description: TODO: Add description to test_marshaller
-module(test_marshaller).

%%
%% Include files
%%
-include_lib("eunit/include/eunit.hrl").

%%
%% Exported Functions
%%
-export([marshal_field/3, marshal_bitmap/1, marshal_wrap/2, unmarshal_field/3, unmarshal_bitmap/1]).

%%
%% API Functions
%%
marshal_field(0, "0200", erl8583_fields) ->
	[0,2,0,0];
marshal_field(0, "0100", erl8583_fields) ->
	"0100";
marshal_field(_N, Value, erl8583_fields) ->
	Value;
marshal_field(_N, Value, foo_rules) ->
	"_" ++ Value;
marshal_field(_N, _Value, erl8583_fields_1993) ->
	"1993".

marshal_bitmap([1, 2, 3]) ->
	"bitmap = 123".

marshal_wrap(_Message, Marshalled) ->
	"Start" ++ Marshalled ++ "End".

unmarshal_field(0, [0,2,0,0|Rest], _) ->
	{"0200", Rest};
unmarshal_field(_, [H|Rest], _) ->
	{[H+$0], Rest}.

unmarshal_bitmap([7|T]) ->
	{[1, 2, 3], T}.

mti_test() ->
	Message = erl8583_message:set(0, "0200", erl8583_message:new()),
	[0, 2, 0, 0] = erl8583_marshaller:marshal(Message, [{field_marshaller, ?MODULE}]).

bitmap_test() ->
	Message0 = erl8583_message:set(0, "0200", erl8583_message:new()),
	Message1 = erl8583_message:set(1, "1", Message0),
	Message2 = erl8583_message:set(2, "1", Message1),	
	Message3 = erl8583_message:set(3, "1", Message2),
	"bitmap = 123" = erl8583_marshaller:marshal(Message3, [{bitmap_marshaller, ?MODULE}]).

fields_test() ->
	Message0 = erl8583_message:set(0, "0100", erl8583_message:new()),
	Message1 = erl8583_message:set(1, "V1", Message0),
	Message2 = erl8583_message:set(2, "V2", Message1),	
	Message3 = erl8583_message:set(3, "V3", Message2),
	"0100V1V2V3" = erl8583_marshaller:marshal(Message3, [{field_marshaller, ?MODULE}]).
	
fields_with_encoding_rules_test() ->
	Message0 = erl8583_message:set(0, "0100", erl8583_message:new()),
	Message1 = erl8583_message:set(1, "V1", Message0),
	Message2 = erl8583_message:set(2, "V2", Message1),	
	Message3 = erl8583_message:set(3, "V3", Message2),
	Options = [{field_marshaller, ?MODULE}, {encoding_rules, foo_rules}],
	"_0100_V1_V2_V3" = erl8583_marshaller:marshal(Message3, Options).

message_wrapping_test() ->
	Message = erl8583_message:set(0, "0200", erl8583_message:new()),
	Options = [{field_marshaller, ?MODULE}, {wrapping_marshaller, ?MODULE}],
	"Start" ++ [0, 2, 0, 0] ++ "End" = erl8583_marshaller:marshal(Message, Options).

encoding_rules_test() ->
	Options = [{field_marshaller, ?MODULE}],
	Message0 = erl8583_message:set(0, "1100", erl8583_message:new()),
	Message1 = erl8583_message:set(1, "V1", Message0),
	"19931993" = erl8583_marshaller:marshal(Message1, Options).

unmarshal_mti_test() ->
	Message = erl8583_marshaller:unmarshal([0, 2, 0, 0], [{field_marshaller, ?MODULE}]),
	[0] = erl8583_message:get_fields(Message).

unmarshal_bitmap_test() ->
	Message = erl8583_marshaller:unmarshal([0, 2, 0, 0, 7, 1, 2, 3], [{field_marshaller, ?MODULE}, {bitmap_marshaller, ?MODULE}]),
	[0, 1, 2, 3] = erl8583_message:get_fields(Message).
	
%%
%% Local Functions
%%

