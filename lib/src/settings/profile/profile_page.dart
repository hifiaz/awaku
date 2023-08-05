import 'package:awaku/service/provider/profile_provider.dart';
import 'package:awaku/service/provider/states/profile_states.dart';
import 'package:awaku/utils/validator.dart';
import 'package:awaku/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  User? user = FirebaseAuth.instance.currentUser;
  final GlobalKey<FormState> _formPersonal = GlobalKey();
  TextEditingController name = TextEditingController();
  TextEditingController height = TextEditingController();
  TextEditingController weight = TextEditingController();
  DateTime? dob;

  @override
  void initState() {
    initialData();
    super.initState();
  }

  void initialData() {
    final profile = ref.read(fetchUserProvider);
    if (profile.hasValue) {
      name = TextEditingController(text: profile.value?.name);
      height = TextEditingController(text: '${profile.value?.height ?? ''}');
      weight = TextEditingController(text: '${profile.value?.weight ?? ''}');
      dob = profile.value?.dob;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(profileProvider, (previous, next) {
      if (next is ProfileStateError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error),
          behavior: SnackBarBehavior.floating,
        ));
      } else if (next is ProfileStateSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Changes updated'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.personalData),
      ),
      body: Form(
        key: _formPersonal,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalizations.of(context)!.yourName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextFormField(
                  controller: name,
                  decoration: InputDecoration(
                    fillColor: Colors.blueGrey[50],
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalizations.of(context)!.dateOfBirth,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(5.0)),
                  height: 150,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: dob ?? DateTime(1969, 1, 1),
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() => dob = newDateTime);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              AppLocalizations.of(context)!.height,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          TextFormField(
                            controller: height,
                            validator: heightRequired,
                            decoration: InputDecoration(
                              fillColor: Colors.blueGrey[50],
                              filled: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              AppLocalizations.of(context)!.weight,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          TextFormField(
                            controller: weight,
                            validator: weightRequired,
                            decoration: InputDecoration(
                              fillColor: Colors.blueGrey[50],
                              filled: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide.none),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                CustomButton(
                  width: double.infinity,
                  isDisabled: false,
                  title: AppLocalizations.of(context)!.saveChanges,
                  onPressed: () {
                    if (_formPersonal.currentState!.validate()) {
                      ref.read(profileProvider.notifier).update(
                          uid: user!.uid,
                          name: name.text,
                          dob: dob,
                          weight: double.parse(weight.text),
                          height: int.parse(height.text));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
