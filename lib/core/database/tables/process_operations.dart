import 'package:drift/drift.dart';

class ProcessOperations extends Table {
  TextColumn get opId => text().named('op_id')();
  TextColumn get family => text().nullable()();
  TextColumn get name => text().nullable()();
  RealColumn get tMinC => real().named('T_min_C').nullable()();
  RealColumn get tMaxC => real().named('T_max_C').nullable()();
  RealColumn get durationMin => real().named('duration_min').nullable()();
  TextColumn get pressure => text().nullable()();
  RealColumn get shearRateS1 => real().named('shear_rate_s-1').nullable()();
  TextColumn get mixingRpm => text().named('mixing_rpm').nullable()();
  RealColumn get energyInput => real().named('energy_input').nullable()();
  RealColumn get coolingRate => real().named('cooling_rate').nullable()();
  RealColumn get heatingRate => real().named('heating_rate').nullable()();
  RealColumn get targetPh => real().named('target_ph').nullable()();
  RealColumn get targetAw => real().named('target_aw').nullable()();
  RealColumn get targetBrix => real().named('target_brix').nullable()();
  RealColumn get particleSizeTargetUm =>
      real().named('particle_size_target_um').nullable()();
  TextColumn get oxygenExposure => text().named('oxygen_exposure').nullable()();
  TextColumn get atmosphere => text().nullable()();
  IntColumn get orderIndex => integer().named('order_index').nullable()();
  TextColumn get additionMode => text().named('addition_mode').nullable()();
  RealColumn get restTime => real().named('rest_time').nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {opId};
}
