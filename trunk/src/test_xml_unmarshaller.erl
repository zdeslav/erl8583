%% Author: carl
%% Created: 29 Jan 2011
%% Description: TODO: Add description to test_xml_unmarshaller
-module(test_xml_unmarshaller).

%%
%% Include files
%%
-include_lib("eunit/include/eunit.hrl").

%%
%% Exported Functions
%%
-export([foo/0]).

%%
%% API Functions
%%
xml_unmarshall_test() ->
	XmlMessage = "<isomsg>" ++
					 "<field id=\"0\" value=\"0800\"/>" ++
					 "<field id=\"3\" value=\"333333\"/>" ++
					 "</isomsg>",
	Message = xml_unmarshaller:unmarshall(XmlMessage),
	?assertEqual("0800", iso8583_message:get(0, Message)),
	?assertEqual("333333", iso8583_message:get(3, Message)),
	?assertEqual([0, 3], iso8583_message:get_fields(Message)).
	
xml_unmarshall_with_text_test() ->
	XmlMessage = "<isomsg>Some text" ++
					 "<field value=\"0800\" id=\"0\">more text</field>" ++
					 "<field id=\"3\" value=\"333333\"/>" ++
					 "</isomsg>",
	Message = xml_unmarshaller:unmarshall(XmlMessage),
	?assertEqual("0800", iso8583_message:get(0, Message)),
	?assertEqual("333333", iso8583_message:get(3, Message)),
	?assertEqual([0, 3], iso8583_message:get_fields(Message)).
	
xml_unmarshall_complex_test() ->
	XmlMessage = "<isomsg>" ++
      "<field id=\"0\" value=\"0810\"/>" ++
      "<field id=\"3\" value=\"333333\"/>" ++
      "<field id=\"39\" value=\"00\"/>" ++
      "<isomsg id=\"48\">" ++
        "<field id=\"1\" value=\"hello\"/>" ++
      "</isomsg>" ++
    "</isomsg>",
	Message = xml_unmarshaller:unmarshall(XmlMessage),
	?assertEqual("0810", iso8583_message:get(0, Message)),
	?assertEqual("333333", iso8583_message:get(3, Message)),
	?assertEqual("00", iso8583_message:get(39, Message)),
	?assertEqual([0, 3, 39, 48], iso8583_message:get_fields(Message)),
	BitMap = iso8583_message:get(48, Message),
	[1] = iso8583_bit_map:get_indexes(BitMap),
	"hello" = iso8583_bit_map:get(1, BitMap).

foo() ->
	{ok, Sock} = gen_tcp:connect("localhost", 8000, [list, {packet, 0}, {active, true}]),
	IsoMsg1 = iso8583_message:new(),
	IsoMsg2 = iso8583_message:set(0, "0800", IsoMsg1),
	IsoMsg3 = iso8583_message:set(3, "333333", IsoMsg2),
	ok = gen_tcp:send(Sock, xml_marshaller:marshall(IsoMsg3)),
	receive {tcp, _, IsoResp} -> IsoResp end,
	IsoResp1 = xml_unmarshaller:unmarshall(IsoResp),
	iso8583_message:get(39, IsoResp1).
	

%%
%% Local Functions
%%

