import 'dart:async';

import 'package:boxorders/utils/message_utils/message_utils.dart';
import 'package:boxorders/widgets/countdown/countdown.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({Key? key}) : super(key: key);
  static const duration = Duration(seconds: 60);
  static const checkupDuration = Duration(seconds: 1);
  static const durationInt = 60;

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage>
    with SingleTickerProviderStateMixin {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;
  Timer? resendTimer;
  late AnimationController resendTime;
  String resendUnable = 'verifyEmail.resendUnable'.tr();

  @override
  void dispose() {
    timer?.cancel();
    resendTimer?.cancel();
    resendTime.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    timer = Timer.periodic(
      VerifyEmailPage.checkupDuration,
      (_) => checkVerificationEmail(),
    );

    resendTime =
        AnimationController(vsync: this, duration: VerifyEmailPage.duration);

    if (isEmailVerified) {
      _checkout();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      sendVerificationEmail();
    });
  }

  @override
  void didUpdateWidget(covariant VerifyEmailPage oldWidget) {
    resendTime.duration = VerifyEmailPage.duration;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 320,
            maxHeight: 160,
          ),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text('verifyEmail.text'.tr()),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: canResendEmail ? sendVerificationEmail : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: canResendEmail
                        ? Text('verifyEmail.resend'.tr())
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(resendUnable),
                              Countdown(
                                animation: StepTween(
                                  begin: VerifyEmailPage.durationInt,
                                  end: 0,
                                ).animate(resendTime),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      resendTime.reset();
      resendTime.forward();
      resendTimer = Timer.periodic(
        VerifyEmailPage.duration,
        (_) => setState(() {
          canResendEmail = true;
        }),
      );
      setState(() {
        canResendEmail = false;
      });

      await user!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      FirebaseAnalytics.instance.logEvent(
          name: 'verifyEmailException',
          parameters: {
            'message': e.message.toString(),
            'stackTrace': e.stackTrace.toString()
          });
      MessageUtils.showTertiarySnackBar('${e.message}', context);
    } catch (e) {
      if (!e.toString().contains('too-many-requests')) {
        debugPrint('$e');
        FirebaseAnalytics.instance.logEvent(
            name: 'verifyEmailException',
            parameters: {'message': e.toString()});
      }
      MessageUtils.showTertiarySnackBar(
        e.toString().split(':').last.split('(').first,
        context,
      );
    }
  }

  void checkVerificationEmail() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified && context.mounted) {
      _checkout();
    }
  }

  void _checkout() {
    context.go('/');
  }
}
