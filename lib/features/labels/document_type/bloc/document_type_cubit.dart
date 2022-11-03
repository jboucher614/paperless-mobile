import 'package:paperless_mobile/core/bloc/label_cubit.dart';
import 'package:paperless_mobile/features/labels/document_type/model/document_type.model.dart';
import 'package:injectable/injectable.dart';

@singleton
class DocumentTypeCubit extends LabelCubit<DocumentType> {
  DocumentTypeCubit(super.metaDataService, super.errorCubit);

  @override
  Future<void> initialize() async {
    return labelRepository.getDocumentTypes().then(loadFrom);
  }

  @override
  Future<DocumentType> save(DocumentType item) =>
      labelRepository.saveDocumentType(item);

  @override
  Future<DocumentType> update(DocumentType item) =>
      labelRepository.updateDocumentType(item);

  @override
  Future<int> delete(DocumentType item) =>
      labelRepository.deleteDocumentType(item);
}
