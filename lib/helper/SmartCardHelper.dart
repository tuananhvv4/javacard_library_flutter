import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_pcsc/flutter_pcsc.dart';
import 'package:javacard_library/helper/helper.dart';

class SmartCardHelper {
  static int? ctx;
  static CardStruct? card;

  static List<int> selectAppletCommand = [
    0x00,
    0xA4,
    0x04,
    0x00,
    0x06,
    0x11,
    0x22,
    0x33,
    0x44,
    0x55,
    0x11,
  ];
  static List<int> setIdApduCommand = [0x00, 0x00, 0x00, 0x00];
  static List<int> getIdApduCommand = [0x00, 0x01, 0x00, 0x00];
  static List<int> setNameApduCommand = [0x00, 0x00, 0x01, 0x00];
  static List<int> getNameApduCommand = [0x00, 0x01, 0x01, 0x00];
  static List<int> setAddressApduCommand = [0x00, 0x00, 0x02, 0x00];
  static List<int> getAddressApduCommand = [0x00, 0x01, 0x02, 0x00];
  static List<int> setPasswordApduCommand = [0x00, 0x00, 0x03, 0x00];
  static List<int> getPasswordApduCommand = [0x00, 0x01, 0x03, 0x00];
  static List<int> setStatusApduCommand = [0x00, 0x00, 0x04, 0x00];
  static List<int> getStatusApdApduCommand = [0x00, 0x01, 0x04, 0x00];
  static List<int> setAvatarApduCommand = [0x00, 0x00, 0x05, 0x00];
  static List<int> getAvatarApduCommand = [0x00, 0x01, 0x05, 0x00];
  static Future<bool> connectApplet(BuildContext context) async {
    /* establish PCSC context */
    ctx = await Pcsc.establishContext(PcscSCope.user);

    try {
      /* get the reader list */
      List<String> readers = await Pcsc.listReaders(ctx!);

      if (readers.isEmpty) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Không kết nối được đến thẻ!'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.red));
        return false;
      } else {
        /* use the first reader */
        String reader = readers[0];

        /* connect to the card */
        card = await Pcsc.cardConnect(
            ctx!, reader, PcscShare.shared, PcscProtocol.any);

        /* send select applet APDU */
        var response = await Pcsc.transmit(card!, selectAppletCommand);

        var sw = response.sublist(response.length - 2);

        if (sw[0] != 0x90 || sw[1] != 0x00) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Không kết nối được đến thẻ!'),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.red));
          return false;
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Kết nối thành công!'),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.green));
          return true;
        }
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Không kết nối được đến thẻ!'),
          backgroundColor: Colors.red));
      return false;
    }
  }

  static Future<void> disconnect() async {
    if (card != null) {
      try {
        /* disconnect from the card */
        await Pcsc.cardDisconnect(card!.hCard, PcscDisposition.resetCard);
      } on Exception catch (e) {
        log(e.toString());
      }
    }
    try {
      /* release PCSC context */
      await Pcsc.releaseContext(ctx!);
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  static Future<List<int>> sendAPDUcommand(List<int> apduCommand) async {
    try {
      /* send applet test command */
      var response = await Pcsc.transmit(card!, apduCommand);
      var sw = response.sublist(response.length - 2);
      var bytes = response.sublist(0, response.length - 2);
      // print(bytes);
      // print(selectAppletCommand);
      // print(
      //     "Mã trạng thái: ${sw.map((e) => e.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ')}");
      // print("Nội dung: ${byteListToString(bytes)}");
      // var text = utf8.decode(bytes);
      // log(text);

      if (sw[0] != 0x90 || sw[1] != 0x00) {
        return [];
      } else {
        return bytes;
      }
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  static Future<bool> sendAPDUcommandAndData(
      List<int> apduCommand, List<int> data) async {
    try {
      /* send applet test command */
      var response =
          await Pcsc.transmit(card!, [...apduCommand, data.length, ...data]);
      var sw = response.sublist(response.length - 2);

      print(
          "Mã trạng thái: ${sw.map((e) => e.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ')}");

      if (sw[0] != 0x90 || sw[1] != 0x00) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      log(e.toString());
      return false;
    }
  }
}
