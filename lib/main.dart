import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// 1. VARIÁVEIS GLOBAIS (ESTRUTURA ESTÁVEL ESTILO C)
final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
Timer? _timer;
const int _notificationId = 999;
const int _ofertaNotificationId = 888;

// Cor Rosa Institucional da Marca
const Color brandPink = Color(0xFFFF1493); 

void main() => runApp(const MeuAppDelivery());

class MeuAppDelivery extends StatelessWidget {
  const MeuAppDelivery({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: brandPink),
        useMaterial3: true,
      ),
      home: const PainelControlePrototype(),
    );
  }
}

class PainelControlePrototype extends StatefulWidget {
  const PainelControlePrototype({super.key});

  @override
  _PainelControlePrototypeState createState() => _PainelControlePrototypeState();
}

class _PainelControlePrototypeState extends State<PainelControlePrototype> {
  String _statusAtual = "Nenhum pedido ativo";

  @override
  void initState() {
    super.initState();
    _configurarEPedirPermissao();
  }

  // Inicializa o canal e PEDE PERMISSÃO ao usuário
  void _configurarEPedirPermissao() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'delivery_channel_id',
      'Status do Delivery',
      description: 'Canal para simulação de Live Updates do pedido',
      importance: Importance.max, // Garante que a notificação tenha alta prioridade
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); 
    
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
        
    // 1. Registra o canal no Android
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 2. Inicializa o plugin (CORREÇÃO DE PARÂMETROS NOMEADOS)
    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Notificação clicada: ${response.payload}");
      },
    );

    // 3. Pede a permissão na tela para o Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Desenha e injeta as informações dinâmicas diretamente na central do Android
  void _atualizarNotificacaoNativa(String status, int passoAtual, int totalPassos) {
    List<AndroidNotificationAction> acoes = [];

    // Se for o ÚLTIMO passo ("Pedido Entregue"), injetamos o botão de avaliação
    if (passoAtual == totalPassos) {
      acoes.add(
        const AndroidNotificationAction(
          'id_avaliar_pedido', // ID que identifica o clique do botão
          '⭐ Avaliar Pedido',   // Texto que vai aparecer no botão para o usuário
          showsUserInterface: true, // Abre o aplicativo ao clicar
        ),
      );
    }

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'delivery_channel_id',
      'Status do Delivery',
      channelDescription: 'Canal para simulação de Live Updates do pedido',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: passoAtual < totalPassos, // SE FOR O ÚLTIMO PASSO, permite o usuário fechar arrastando!
      onlyAlertOnce: true,
      showProgress: passoAtual < totalPassos, // Desativa a barra de progresso no último passo
      maxProgress: totalPassos,
      progress: passoAtual,
      actions: acoes, // Injeta a lista de botões aqui
      color: brandPink, // APLICA COR ROSA INSTITUCIONAL NO ANDROID
      colorized: true,  // HABILITA A COLORIZAÇÃO DO CARD INTEIRO NO SEU ROSA
      styleInformation: const BigTextStyleInformation(
        '', // Usaremos o body dinâmico passado no .show
        htmlFormatContent: true, // Habilita formatação HTML para o corpo
        htmlFormatTitle: true,   // Habilita formatação HTML para o título
      ),
    );

    NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    // Envia o comando para o Sistema Operacional Android desenhar na barra (CORREÇÃO DE PARÂMETROS NOMEADOS)
    _notificationsPlugin.show(
      id: _notificationId,
      title: '<b>Seu pedido na Amo 🩷</b>', // Usando tag HTML <b> para destaque
      body: 'Status: <b>$status</b>', // HTML dinâmico no corpo da mensagem
      notificationDetails: notificationDetails,
    );
  }

  void _limparNotificacao() {
    _notificationsPlugin.cancel(id: _notificationId);
  }

  // Dispara a Notificação de Oferta com Contagem Regressiva Nativa e Fundo Rosa
  void _enviarCredito() {
    // Calculamos o tempo exato de 1 minuto (60.000 milissegundos) a partir de AGORA
    final int tempoFinalEmMilissegundos = DateTime.now().millisecondsSinceEpoch + 60000;

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'ofertas_channel_id', // Um novo canal focado em marketing
      'Ofertas Relâmpago',
      channelDescription: 'Canal para cupons e ofertas com tempo limitado',
      importance: Importance.max,
      priority: Priority.high,
      color: brandPink, // APLICA COR ROSA INSTITUCIONAL NO CARD
      colorized: true,  // HABILITA A COLORIZAÇÃO COMPLETA

      // Habilita tags HTML no título e no corpo usando BigTextStyleInformation
      styleInformation: const BigTextStyleInformation(
        '',
        htmlFormatContent: true, 
        htmlFormatTitle: true,   
      ),
      
      // CRONÔMETRO INTEGRADO:
      usesChronometer: true, // Diz ao Android para mostrar um relógio
      chronometerCountDown: true, // Diz para o relógio contar para TRÁS (regressivo)
      when: tempoFinalEmMilissegundos, // Passa o momento exato em que ele deve zerar
    );

    NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    // CORREÇÃO DE PARÂMETROS NOMEADOS
    _notificationsPlugin.show(
      id: _ofertaNotificationId, 
      title: 'você ganhou <b>R\$ 10</b> no App! 💲', 
      body: 'seu crédito está expirando em: <font color="#FFFF00"><b>CORRE!🏃‍♂️</b></font>', // Usei Amarelo (#FFFF00) para excelente contraste sob o fundo Rosa
      notificationDetails: notificationDetails,
    );
  }

  // Motor do Protótipo
  void _iniciarFluxoDeProducao() {
    List<String> passos = [
      "Pedido Confirmado 📝",
      "Pedido em Produção 👨‍🍳",
      "Saiu para Entrega! 🏍️",
      "Pedido Entregue! Bom apetite"
    ];
    
    int aktual = 0;
    _timer?.cancel(); 

    setState(() => _statusAtual = passos[aktual]);
    _atualizarNotificacaoNativa(passos[aktual], aktual + 1, passos.length);

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      aktual++;
      if (aktual < passos.length) {
        setState(() => _statusAtual = passos[aktual]);
        _atualizarNotificacaoNativa(passos[aktual], aktual + 1, passos.length);
      } else {
        timer.cancel();
        Future.delayed(const Duration(seconds: 4), () {
          _limparNotificacao();
          setState(() => _statusAtual = "Nenhum pedido ativo");
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Actions Demo'),
        backgroundColor: brandPink,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Protótipo demo live actions",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 4,
              color: const Color(0xFFFCE4EC), // Um tom de rosa bem clarinho para o fundo do card interno
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  _statusAtual,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: brandPink, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // BOTÃO 1: Fluxo de Entrega (Rosa da Marca)
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow, size: 24),
              label: const Text("Fluxo de Entrega", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: brandPink,
                foregroundColor: Colors.white,
              ),
              onPressed: _iniciarFluxoDeProducao,
            ),
            
            const SizedBox(height: 16), // Espaçamento entre os botões
            
            // BOTÃO 2: Crédito (Rosa delineado)
            OutlinedButton.icon(
              icon: const Icon(Icons.currency_exchange, size: 24),
              label: const Text("Créditos com contagem regressiva", style: TextStyle(fontSize: 16)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: brandPink, width: 2),
                foregroundColor: brandPink,
              ),
              onPressed: _enviarCredito, 
            ),
          ],
        ),
      ),
    );
  }
}