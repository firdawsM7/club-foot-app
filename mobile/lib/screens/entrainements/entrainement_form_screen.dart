import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/training_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/models.dart';

class EntrainementFormScreen extends StatefulWidget {
  final Entrainement? training;

  const EntrainementFormScreen({super.key, this.training});

  @override
  State<EntrainementFormScreen> createState() => _EntrainementFormScreenState();
}

class _EntrainementFormScreenState extends State<EntrainementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late TextEditingController _lieuController;
  late TextEditingController _dureeController;
  late TextEditingController _objectifController;
  late TextEditingController _exercicesController;
  late TextEditingController _notesController;
  int? _selectedEquipeId;
  String _selectedStatut = 'PLANIFIE';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.training;
    if (t != null) {
      final dt = DateTime.parse(t.dateHeure);
      _selectedDate = DateTime(dt.year, dt.month, dt.day);
      _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
      _lieuController = TextEditingController(text: t.lieu);
      _dureeController = TextEditingController(text: t.duree?.toString() ?? '');
      _objectifController = TextEditingController(text: t.objectif ?? '');
      _exercicesController = TextEditingController(text: t.exercices ?? '');
      _notesController = TextEditingController(text: t.notes ?? '');
      _selectedEquipeId = t.equipeId;
      _selectedStatut = t.statut;
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _lieuController = TextEditingController();
      _dureeController = TextEditingController();
      _objectifController = TextEditingController();
      _exercicesController = TextEditingController();
      _notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _lieuController.dispose();
    _dureeController.dispose();
    _objectifController.dispose();
    _exercicesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedEquipeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une équipe')),
        );
        return;
      }

      setState(() => _isSaving = true);

      final combinedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final newTraining = Entrainement(
        id: widget.training?.id,
        equipeId: _selectedEquipeId!,
        dateHeure: combinedDateTime.toIso8601String(),
        lieu: _lieuController.text,
        duree: int.tryParse(_dureeController.text),
        objectif: _objectifController.text,
        exercices: _exercicesController.text,
        statut: _selectedStatut,
        notes: _notesController.text,
      );

      final provider = context.read<TrainingProvider>();
      final Future<bool> operation = widget.training == null
          ? provider.addTraining(newTraining)
          : provider.updateTraining(newTraining);

      operation.then((success) {
        setState(() => _isSaving = false);
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.training == null ? 'Entraînement créé' : 'Entraînement modifié')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${provider.error}')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Note: In a real app, you would fetch equipes from a Provider.
    // For now, let's assume we have a few for selection if they are not in DashboardProvider
    // Or just use a simple List for demo purpose if we can't get them easily.
    // Let's try to get them from DashboardProvider if available.
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.training == null ? 'Nouvel Entraînement' : 'Modifier l\'Entraînement'),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getGradient(context)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildEquipeDropdown(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Date'),
                        subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('Heure'),
                        subtitle: Text(_selectedTime.format(context)),
                        trailing: const Icon(Icons.access_time),
                        onTap: () => _selectTime(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lieuController,
                  decoration: const InputDecoration(labelText: 'Lieu', prefixIcon: Icon(Icons.location_on)),
                  validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dureeController,
                  decoration: const InputDecoration(labelText: 'Durée (minutes)', prefixIcon: Icon(Icons.timer)),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _objectifController,
                  decoration: const InputDecoration(labelText: 'Objectif', prefixIcon: Icon(Icons.track_changes)),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _exercicesController,
                  decoration: const InputDecoration(labelText: 'Exercices', prefixIcon: Icon(Icons.list)),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatut,
                  decoration: const InputDecoration(labelText: 'Statut', prefixIcon: Icon(Icons.info_outline)),
                  items: ['PLANIFIE', 'EN_COURS', 'TERMINE', 'ANNULE']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedStatut = value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Notes', prefixIcon: Icon(Icons.note)),
                  maxLines: 2,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.masYellow,
                    foregroundColor: AppTheme.masBlack,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: AppTheme.masBlack)
                      : Text(widget.training == null ? 'CRÉER' : 'ENREGISTRER'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEquipeDropdown() {
    // Simple placeholder for equipe selection
    // In a real app, fetch these from an EquipeProvider
    return DropdownButtonFormField<int>(
      initialValue: _selectedEquipeId,
      decoration: const InputDecoration(labelText: 'Équipe', prefixIcon: Icon(Icons.groups)),
      items: [1, 2, 3] // Placeholder IDs
          .map((id) => DropdownMenuItem(value: id, child: Text('Équipe $id')))
          .toList(),
      onChanged: (value) {
        if (value != null) setState(() => _selectedEquipeId = value);
      },
      validator: (value) => value == null ? 'Veuillez sélectionner une équipe' : null,
    );
  }
}
