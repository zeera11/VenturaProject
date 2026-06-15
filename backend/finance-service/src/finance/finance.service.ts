import { Injectable } from '@nestjs/common';
import { db } from '../config/firebase.config';

@Injectable()
export class FinanceService {
  async addExpense(dto: any, userId: string) {
    const docRef = await db.collection('expenses').add({
      ...dto,
      userId: userId || null,
      createdAt: new Date().toISOString(),
    });

    return {
      message: 'Expense added',
      id: docRef.id,
    };
  }

  async updateExpense(id: string, dto: any, userId: string) {
    const docRef = db.collection('expenses').doc(id);
    const doc = await docRef.get();
    if (!doc.exists) {
      return { message: 'Expense not found' };
    }
    const data = doc.data();
    if (data?.userId !== userId) {
      return { message: 'Unauthorized' };
    }

    const updateData: any = {};
    if (dto.title !== undefined) updateData.title = dto.title;
    if (dto.amount !== undefined) updateData.amount = dto.amount;
    if (dto.category !== undefined) updateData.category = dto.category;
    if (dto.date !== undefined) updateData.date = dto.date;

    await docRef.update(updateData);
    return {
      message: 'Expense updated',
      id,
    };
  }

  async deleteExpense(id: string, userId: string) {
    const doc = await db.collection('expenses').doc(id).get();
    if (!doc.exists) {
      return { message: 'Expense not found' };
    }
    const data = doc.data();
    if (data?.userId !== userId) {
      return { message: 'Unauthorized' };
    }
    await db.collection('expenses').doc(id).delete();
    return { message: 'Expense deleted' };
  }

  async clearExpenses(userId: string) {
    const existing = await db
      .collection('expenses')
      .where('userId', '==', userId)
      .get();

    const batch = db.batch();
    existing.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();

    return { message: 'All expenses cleared' };
  }

  async addBudget(dto: any, userId: string) {
    // Hapus budget lama user jika ada (hanya satu budget aktif per user)
    const existing = await db
      .collection('budgets')
      .where('userId', '==', userId)
      .get();

    const batch = db.batch();
    existing.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();

    const docRef = await db.collection('budgets').add({
      ...dto,
      userId: userId || null,
      createdAt: new Date().toISOString(),
    });

    return {
      message: 'Budget set',
      id: docRef.id,
    };
  }

  async getAll(userId: string) {
    const expensesSnap = await db
      .collection('expenses')
      .where('userId', '==', userId)
      .get();

    const budgetsSnap = await db
      .collection('budgets')
      .where('userId', '==', userId)
      .get();

    const expenses = expensesSnap.docs.map((doc) => ({
      id: doc.id,
      ...doc.data() as any,
    }));

    const budgets = budgetsSnap.docs.map((doc) => ({
      id: doc.id,
      ...doc.data() as any,
    }));

    const totalSpent = expenses.reduce(
      (sum, expense) => sum + Number(expense.amount || 0),
      0,
    );

    const totalBudget = budgets.reduce(
      (sum, budget) => sum + Number(budget.totalBudget || 0),
      0,
    );

    const remainingBudget = totalBudget - totalSpent;

    const percentageUsed =
      totalBudget > 0
        ? Number(((totalSpent / totalBudget) * 100).toFixed(2))
        : 0;

    const status =
      totalSpent > totalBudget
        ? 'OVER'
        : totalSpent > totalBudget * 0.8
        ? 'WARNING'
        : 'SAFE';

    return {
      userId,
      expenses,
      budgets,
      totalBudget,
      totalSpent,
      remainingBudget,
      percentageUsed,
      status,
    };
  }

  async getSummary(userId: string) {
    const expensesSnap = await db
      .collection('expenses')
      .where('userId', '==', userId)
      .get();

    const budgetsSnap = await db
      .collection('budgets')
      .where('userId', '==', userId)
      .get();

    const expenses = expensesSnap.docs.map((doc) => doc.data() as any);
    const budgets = budgetsSnap.docs.map((doc) => doc.data() as any);

    const totalSpent = expenses.reduce(
      (sum, expense) => sum + Number(expense.amount || 0),
      0,
    );

    const totalBudget = budgets.reduce(
      (sum, budget) => sum + Number(budget.totalBudget || 0),
      0,
    );

    const remainingBudget = totalBudget - totalSpent;

    const percentageUsed =
      totalBudget > 0
        ? Number(((totalSpent / totalBudget) * 100).toFixed(2))
        : 0;

    // Kelompokkan pengeluaran per kategori
    const byCategory: Record<string, number> = {};
    expenses.forEach((e) => {
      const cat = e.category || 'other';
      byCategory[cat] = (byCategory[cat] || 0) + Number(e.amount || 0);
    });

    return {
      totalBudget,
      totalSpent,
      remainingBudget,
      percentageUsed,
      byCategory,
      status:
        totalSpent > totalBudget
          ? 'OVER'
          : totalSpent > totalBudget * 0.8
          ? 'WARNING'
          : 'SAFE',
    };
  }
}