import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:web_service/services/via_cep_service.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _searchCepController = TextEditingController();
  bool _loading = false;
  bool _isCepValid = false;
  bool _enableField = true;
  String? _result;
  String _shareResult = '';

  @override
  void dispose() {
    super.dispose();
    _searchCepController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Consultar CEP',
          style: TextStyle(
              fontWeight: FontWeight.w900, fontSize: 25, letterSpacing: 2),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Show Snackbar',
            onPressed: () => _onShare(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSearchCepTextField(),
            _buildSearchCepButton(),
            _buildResultForm()
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCepTextField() {
    return TextField(
      autofocus: true,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(labelText: 'Cep'),
      style: const TextStyle(fontSize: 20),
      controller: _searchCepController,
      enabled: _enableField,
    );
  }

  Widget _buildSearchCepButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: RaisedButton(
        onPressed: _searchCep,
        child: _loading ? _circularLoading() : Text('Consultar'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _searching(bool enable) {
    setState(() {
      _result = enable ? '' : _result;
      _loading = enable;
      _enableField = !enable;
    });
  }

  Widget _circularLoading() {
    return Container(
      height: 15.0,
      width: 15.0,
      child: CircularProgressIndicator(),
    );
  }

  Future _searchCep() async {
    _searching(true);

    final cep = _searchCepController.text;

    try {
      if (cep.length == 8) {
        final resultCep = await ViaCepService.fetchCep(cep: cep);
        setState(() {
          _result = resultCep.toJson();
          _isCepValid = true;
        });
        _searching(false);
      } else {
        await Flushbar(
          message: 'O CEP deve conter 8 digitos.',
          duration: const Duration(seconds: 2),
        ).show(context);
        _isCepValid = false;
        _searching(false);
      }
    } catch (e) {
      setState(() {
        _buildValidatorFlushbar(e.toString());
        _result = e.toString();
        _isCepValid = false;
      });
      _searching(false);
    }
  }

  Future<Widget> _buildValidatorFlushbar(mensagem) async => Flushbar(
      title: "Erro", message: mensagem, duration: const Duration(seconds: 2));

  Widget _buildResultForm() {
    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      child: Text(_result ?? ''),
    );
  }

  void _onShare() async {
    if (_isCepValid) {
      _shareResult = _result!;
      await Share.share(_shareResult);
    } else {
      await Flushbar(
        message: 'Consulte um CEP antes de compartilhar',
        duration: const Duration(seconds: 3),
      ).show(context);
    }
  }
}
