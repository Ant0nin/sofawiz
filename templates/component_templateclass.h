#ifndef SOFA_COMPONENT__COMPONENTTYPE___COMPONENTNAME__H
#define SOFA_COMPONENT__COMPONENTTYPE___COMPONENTNAME__H

#include <sofa/core/ObjectFactory.h>
#include <_motherLocation_.h>

_namespacebegin_

   template<_typenameTemplateArgs_ >
   class _ComponentName_ : public _MotherClass_<_motherTemplateArgs_>
   {
    public:

     SOFA_CLASS( SOFA_TEMPLATE_templateArgsCount_(_ComponentName_, _templateArgs_), SOFA_TEMPLATE_motherTemplateArgsCount_(_MotherClass_, _motherTemplateArgs_) );

     // TODO: complete class definition
   };

_namespaceend_

#endif
